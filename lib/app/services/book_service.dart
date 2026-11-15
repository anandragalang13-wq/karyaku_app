import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../data/book_covers.dart';
import '../data/models/book_model.dart';
import '../data/models/book_model_extension.dart';
import '../data/models/review_model.dart';
import '../data/models/review_model_extension.dart';
import '../data/models/work_model.dart';
import 'supabase_auth_service.dart';

/// Akses data karya (tabel `books`), ulasan (`reviews`), dan cover (Storage).
/// RLS di Supabase membuat publik hanya melihat karya `approved`.
class BookService extends GetxService {
  /// Client Supabase. Dibuat lewat getter supaya service bisa diuji
  /// ( subclass dapat menimpanya ) tanpa harus menginisialisasi Supabase.
  SupabaseClient get supabase => Supabase.instance.client;

  static const String coversBucket = 'covers';

  // ------------------------------------------------------------------
  // BACA
  // ------------------------------------------------------------------

  /// Karya approved, diurutkan dari yang paling banyak dilihat.
  /// Dipakai Beranda (WorkModel). Melempar error bila query gagal supaya
  /// pemanggil bisa membedakan "database kosong" dari "gagal terhubung".
  Future<List<WorkModel>> getApprovedWorks() async {
    final response = await supabase
        .from(SupabaseConfig.booksTable)
        .select()
        .eq('approval_status', 'approved')
        .order('views_count', ascending: false);

    return (response as List)
        .map((e) => _workFromRow(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Semua karya milik penulis yang login (semua status, termasuk draft).
  /// RLS mengizinkan penulis melihat karyanya sendiri.
  Future<List<WorkModel>> getMyWorks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from(SupabaseConfig.booksTable)
        .select()
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => _workFromRow(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<BookModel>> getPopularBooks({int limit = 10}) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('approval_status', 'approved')
          .order('views_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      print('Get popular books error: $e');
      return [];
    }
  }

  Future<List<BookModel>> searchBooks({
    String query = '',
    String category = 'Semua',
  }) async {
    try {
      var builder = supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('approval_status', 'approved');

      if (query.trim().isNotEmpty) {
        builder = builder.ilike('title', '%${query.trim()}%');
      }
      if (category.isNotEmpty && category != 'Semua') {
        builder = builder.eq('category', category);
      }

      final response = await builder.order('views_count', ascending: false);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      print('Search books error: $e');
      return [];
    }
  }

  /// Semua karya approved, terbaru dulu.
  Future<List<BookModel>> getAllBooks() async {
    try {
      final response = await supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      print('Get books error: $e');
      return [];
    }
  }

  // ------------------------------------------------------------------
  // PERPUSTAKAAN (riwayat baca & koleksi per user)
  // ------------------------------------------------------------------

  /// Karya yang pernah dibuka/dibaca user login, terbaru dulu, lengkap
  /// dengan progres baca milik user tersebut.
  ///
  /// Mengembalikan daftar kosong bila user belum pernah membaca apa pun
  /// (atau belum login) — halaman Perpustakaan lalu menampilkan keadaan
  /// kosong, bukan daftar karya dummy.
  Future<List<BookModel>> getReadingHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await supabase
        .from(SupabaseConfig.readingHistoryTable)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    final list = rows as List;
    if (list.isEmpty) return [];

    // Simpan posisi baca per karya, lalu ambil data karyanya.
    final positionByBook = <String, Map<String, dynamic>>{};
    final bookIds = <String>[];
    for (final row in list) {
      final r = Map<String, dynamic>.from(row as Map);
      final id = r['book_id']?.toString() ?? '';
      if (id.isEmpty || positionByBook.containsKey(id)) continue;
      positionByBook[id] = r;
      bookIds.add(id);
    }

    final books = await _booksByIds(bookIds);
    return [
      for (final book in books)
        book.copyWith(
          currentChapter:
              (positionByBook[book.id]?['last_chapter'] as num?)?.toInt() ?? 1,
          progress: ((positionByBook[book.id]?['progress'] as num?)
                      ?.toDouble() ??
                  0)
              .clamp(0.0, 1.0)
              .toDouble(),
        ),
    ];
  }

  /// Mencatat interaksi user dengan sebuah karya untuk halaman Perpustakaan.
  ///
  /// - Tanpa [chapter]: menandai bahwa karya pernah dibuka — baris baru
  ///   dibuat pada bab 1, baris lama hanya stempel waktunya diperbarui
  ///   (progres lama tidak ditimpa).
  /// - Dengan [chapter]: menyimpan posisi bab terakhir + progres baca.
  ///
  /// Best-effort: kegagalan dicatat ke log tanpa mengganggu proses membaca.
  Future<void> recordReading({
    required String bookId,
    int? chapter,
    int totalChapters = 1,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || bookId.isEmpty) return;

    try {
      final total = totalChapters < 1 ? 1 : totalChapters;
      final now = DateTime.now().toUtc().toIso8601String();
      final table = SupabaseConfig.readingHistoryTable;

      final existing = await supabase
          .from(table)
          .select('id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      if (existing == null) {
        final startChapter = chapter ?? 1;
        await supabase.from(table).insert({
          'user_id': userId,
          'book_id': bookId,
          'last_chapter': startChapter,
          'progress': (startChapter / total).clamp(0.0, 1.0).toDouble(),
          'updated_at': now,
        });
      } else if (chapter != null) {
        await supabase.from(table).update({
          'last_chapter': chapter,
          'progress': (chapter / total).clamp(0.0, 1.0).toDouble(),
          'updated_at': now,
        }).eq('id', existing['id']);
      } else {
        await supabase
            .from(table)
            .update({'updated_at': now}).eq('id', existing['id']);
      }
    } catch (e) {
      print('Record reading error: $e');
    }
  }

  /// Koleksi karya milik user login (terbaru dulu). Kosong bila user
  /// belum pernah menambahkan karya ke koleksinya.
  Future<List<BookModel>> getCollectionBooks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await supabase
        .from(SupabaseConfig.collectionsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final list = rows as List;
    if (list.isEmpty) return [];

    final bookIds = [
      for (final row in list)
        (row as Map)['book_id']?.toString() ?? '',
    ].where((id) => id.isNotEmpty).toList();

    return _booksByIds(bookIds);
  }

  /// Apakah karya sudah disimpan (di-bookmark) oleh user login?
  /// Dipakai tombol Save di halaman Detail Buku.
  Future<bool> isSaved(String bookId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || bookId.isEmpty) return false;

    final row = await supabase
        .from(SupabaseConfig.collectionsTable)
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();
    return row != null;
  }

  /// Menambahkan karya ke koleksi user (idempoten bila sudah ada).
  Future<void> addToCollection(String bookId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || bookId.isEmpty) return;

    await supabase.from(SupabaseConfig.collectionsTable).upsert(
      {'user_id': userId, 'book_id': bookId},
      onConflict: 'user_id,book_id',
      ignoreDuplicates: true,
    );
  }

  /// Menghapus karya dari koleksi user.
  Future<void> removeFromCollection(String bookId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || bookId.isEmpty) return;

    await supabase
        .from(SupabaseConfig.collectionsTable)
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  /// Mengambil karya berdasarkan daftar id (urutan mengikuti [bookIds]).
  /// Id yang tidak ditemukan — sudah dihapus atau tidak boleh dilihat
  /// karena RLS — diabaikan.
  Future<List<BookModel>> _booksByIds(List<String> bookIds) async {
    if (bookIds.isEmpty) return [];

    final books = await supabase
        .from(SupabaseConfig.booksTable)
        .select()
        .inFilter('id', bookIds);

    final byId = <String, Map<String, dynamic>>{
      for (final b in books as List)
        (b as Map)['id'].toString(): Map<String, dynamic>.from(b),
    };

    return [
      for (final id in bookIds)
        if (byId[id] != null) BookModelExtension.fromJson(byId[id]!),
    ];
  }

  Future<List<ReviewModel>> getReviews(String bookId) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.reviewsTable)
          .select()
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ReviewModelExtension.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      print('Get reviews error: $e');
      return [];
    }
  }

  /// Jumlah ulasan tiap buku (dipakai statistik karya di halaman Kelola Karya).
  /// Gagal menghitung bukanlah error fatal, jadi selalu menghasilkan peta
  /// (kosong bila terjadi masalah).
  Future<Map<String, int>> countReviewsByBook(List<String> bookIds) async {
    if (bookIds.isEmpty) return {};

    try {
      final response = await supabase
          .from(SupabaseConfig.reviewsTable)
          .select('book_id')
          .inFilter('book_id', bookIds);

      final counts = <String, int>{};
      for (final row in response as List) {
        final id = Map<String, dynamic>.from(row as Map)['book_id']?.toString();
        if (id == null) continue;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      print('Count reviews error: $e');
      return {};
    }
  }

  // ------------------------------------------------------------------
  // TULIS
  // ------------------------------------------------------------------

  /// Mengirim ulasan. Mengembalikan true jika tersimpan.
  Future<bool> addReview({
    required String bookId,
    required int rating,
    required String comment,
    required String userName,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await supabase.from(SupabaseConfig.reviewsTable).insert({
        'book_id': bookId,
        'user_id': userId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
      });
      return true;
    } catch (e) {
      print('Add review error: $e');
      return false;
    }
  }

  /// Upload cover ke Storage (bucket `covers`, folder = id user) dan
  /// mengembalikan URL publiknya.
  Future<String> uploadCover(XFile file) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Belum login.');

    final bytes = await file.readAsBytes();
    final dot = file.name.lastIndexOf('.');
    final ext = dot >= 0 ? file.name.substring(dot + 1).toLowerCase() : 'jpg';
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(coversBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: false),
        );
    return supabase.storage.from(coversBucket).getPublicUrl(path);
  }

  /// Menyimpan karya baru. `submit: false` → draft, `true` → pending
  /// (menunggu approval admin).
  Future<void> saveWork({
    required String title,
    required String category, // Novel | Puisi | Cerpen
    required String content,
    String? synopsis,
    List<String> tags = const [],
    String? coverUrl,
    required bool submit,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Belum login.');

    final user = SupabaseAuthService.to.currentUser.value;
    final author = (user != null && user.penName.isNotEmpty)
        ? user.penName
        : (user?.name ?? 'Penulis');

    await supabase.from(SupabaseConfig.booksTable).insert({
      'author_id': userId,
      'author': author,
      'title': title,
      'category': category,
      'content': content,
      'synopsis': (synopsis == null || synopsis.trim().isEmpty) ? null : synopsis.trim(),
      'tags': tags,
      'cover_asset': coverUrl,
      'status': 'Ongoing',
      'approval_status': submit ? 'pending' : 'draft',
      'submitted_at': submit ? DateTime.now().toUtc().toIso8601String() : null,
      'total_chapters': 1,
      'current_chapter': 0,
    });
  }

  /// Menyimpan bab baru pada sebuah karya: isi diperbarui (blok bab baru
  /// ditambahkan di akhir) beserta jumlah bab-nya.
  ///
  /// Hanya berhasil untuk karya yang masih boleh diedit penulis
  /// (draft / ditolak) sesuai kebijakan RLS di `supabase/schema.sql`.
  Future<void> saveChapter({
    required String bookId,
    required String content,
    required int totalChapters,
    required int currentChapter,
  }) async {
    await supabase.from(SupabaseConfig.booksTable).update({
      'content': content,
      'total_chapters': totalChapters,
      'current_chapter': currentChapter,
    }).eq('id', bookId);
  }

  /// Menyimpan perubahan isi karya (fitur "Edit Karya") **tanpa** mengubah
  /// progres baca `current_chapter` maupun jumlah bab.
  ///
  /// Hanya berhasil untuk karya milik penulis sendiri (RLS
  /// `books_update_own` di `supabase/schema.sql`).
  Future<void> saveWorkContent({
    required String bookId,
    required String content,
  }) async {
    await supabase
        .from(SupabaseConfig.booksTable)
        .update({'content': content}).eq('id', bookId);
  }

  /// Menghapus karya milik penulis sendiri.
  ///
  /// Hanya berhasil untuk karya miliknya sendiri sesuai kebijakan RLS
  /// `books_delete_own` di `supabase/schema.sql`.
  Future<void> deleteWork(String bookId) async {
    await supabase
        .from(SupabaseConfig.booksTable)
        .delete()
        .eq('id', bookId);
  }

  // ------------------------------------------------------------------
  // MAPPER
  // ------------------------------------------------------------------

  WorkModel _workFromRow(Map<String, dynamic> j) {
    final category = (j['category'] as String? ?? 'Novel').toLowerCase();
    final type = WorkType.values.firstWhere(
      (t) => t.name == category,
      orElse: () => WorkType.novel,
    );
    final approval = ApprovalStatus.values.firstWhere(
      (a) => a.name == (j['approval_status'] as String? ?? 'draft'),
      orElse: () => ApprovalStatus.draft,
    );

    return WorkModel(
      id: j['id']?.toString() ?? '',
      authorId: j['author_id']?.toString() ?? '',
      authorName: j['author'] as String?,
      title: j['title'] as String? ?? 'No Title',
      type: type,
      cover: BookCovers.resolve(
        cover: j['cover_asset'] as String?,
        title: j['title'] as String?,
      ),
      content: j['content'] as String? ?? '',
      synopsis: j['synopsis'] as String?,
      tags: List<String>.from(j['tags'] as List? ?? []),
      approvalStatus: approval,
      rejectionReason: j['rejection_reason'] as String?,
      createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      submittedAt: DateTime.tryParse(j['submitted_at'] as String? ?? ''),
      approvedAt: DateTime.tryParse(j['approved_at'] as String? ?? ''),
      views: (j['views_count'] as num?)?.toInt() ?? 0,
      rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
      chapterCount: (j['total_chapters'] as num?)?.toInt() ?? 1,
    );
  }
}
