import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/book_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/work_model.dart';
import '../../../data/models/work_model_exension.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';
import '../../../theme/app_colors.dart';

/// Controller halaman Detail Buku: menampilkan sinopsis, ulasan, dan
/// aksi simpan (bookmark) / bagikan / mulai baca.
class DetailBukuController extends GetxController {
  late final BookModel book;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isSynopsisExpanded = false.obs;

  /// Status "karya ini sudah disimpan user" — disimpan nyata di tabel
  /// `user_collections` (lihat [BookService.isSaved]/[addToCollection]).
  final RxBool isBookmarked = false.obs;

  /// Follow state
  final RxBool isFollowing = false.obs;
  final RxInt followersCount = 0.obs;

  BookService get _books => Get.find<BookService>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is BookModel) {
      book = args;
    } else if (args is WorkModel) {
      book = args.toBookModel();
    } else {
      // Dibuka tanpa argumen → tampilkan karya kosong, BUKAN data dummy.
      book = const BookModel(
        id: '',
        title: '',
        author: '',
        category: 'Novel',
        rating: 0,
        views: 0,
        totalChapters: 0,
        synopsis: '',
        tags: [],
        coverGradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      );
    }
    _loadSaveState();
    _loadFollowState();
    // Mencatat bahwa user pernah membuka karya ini → muncul di tab
    // Histori halaman Perpustakaan (best-effort, tanpa chapter supaya
    // posisi baca lama tidak ditimpa). Semua akses DB dijaga supaya
    // halaman tetap terbuka walau service belum terdaftar.
    if (Get.isRegistered<BookService>()) {
      _loadReviews();
      _books.recordReading(bookId: book.id, totalChapters: book.totalChapters);
    }
  }

  Future<void> _loadFollowState() async {
    if (!Get.isRegistered<BookService>() || book.authorId.isEmpty) return;
    try {
      isFollowing.value = await _books.isFollowing(book.authorId);
      followersCount.value = await _books.getFollowersCount(book.authorId);
    } catch (e) {
      print('Load follow state error: $e');
    }
  }

  Future<void> _loadReviews() async {
    if (!Get.isRegistered<BookService>()) return;
    try {
      final list = await _books.getReviews(book.id);
      reviews.assignAll(list);
    } catch (e) {
      print('Load reviews error: $e');
    }
  }

  /// Membaca status simpanan karya ini dari database supaya ikon bookmark
  /// sesuai dengan daftar simpanan user saat halaman dibuka.
  Future<void> _loadSaveState() async {
    if (!Get.isRegistered<BookService>() || book.id.isEmpty) return;
    try {
      isBookmarked.value = await _books.isSaved(book.id);
    } catch (e) {
      print('Load save state error: $e');
    }
  }

  void toggleSynopsis() => isSynopsisExpanded.toggle();

  /// Menyimpan / membatalkan simpanan karya (bookmark) secara real ke
  /// tabel `user_collections`. Ikon berubah optimistis, lalu dikunci ulang
  /// bila penyimpanan gagal.
  void toggleBookmark() {
    if (!isLoggedIn) {
      promptLoginToSave();
      return;
    }
    _toggleBookmarkAsync();
  }

  Future<void> _toggleBookmarkAsync() async {
    final wasSaved = isBookmarked.value;
    isBookmarked.value = !wasSaved;
    try {
      if (wasSaved) {
        await _books.removeFromCollection(book.id);
        Get.snackbar(
          'book_unsave_title'.tr,
          'book_unsave_message'.trArgs([book.title]),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryNavy,
          colorText: Colors.white,
        );
      } else {
        await _books.addToCollection(book.id);
        Get.snackbar(
          'book_save_title'.tr,
          'book_save_message'.trArgs([book.title]),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isBookmarked.value = wasSaved; // batalkan perubahan optimistis
      Get.snackbar(
        'book_save_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      print('Toggle save error: $e');
    }
  }

  void promptLoginToSave() {
    Get.snackbar(
      'book_save_login_required_title'.tr,
      'book_save_login_required_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed(Routes.LOGIN);
  }

  /// Teks yang dibagikan: judul, penulis, dan deep link ke karya ini.
  /// Dipakai [shareBook] — sengaja berupa method murni supaya bisa dites.
  String get shareText =>
      'book_share_text'.trArgs([book.title, book.author, shareLink]);

  /// Deep link karya di dalam aplikasi (skema `karyaku://book/<id>` sudah
  /// terdaftar di AndroidManifest & Info.plist).
  String get shareLink => 'karyaku://book/${book.id}';

  /// Membagikan detail karya ke aplikasi lain (WhatsApp, Telegram, dll)
  /// memakai dialog share bawaan sistem.
  Future<void> shareBook() async {
    try {
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e) {
      Get.snackbar(
        'book_share_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      print('Share error: $e');
    }
  }

  void startReading() => Get.toNamed(Routes.READER, arguments: book);

  /// Status login pengguna saat ini. Hanya bergantung pada sesi Supabase
  /// (`isLoggedIn`), BUKAN pada `currentUser` (profil dari tabel `users`),
  /// supaya profil yang gagal termuat tidak membuat user dianggap logout.
  /// Service tidak terdaftar (mis. di lingkup test) dianggap belum login.
  bool get isLoggedIn =>
      Get.isRegistered<AuthService>() && AuthService.to.isLoggedIn.value;

  void promptLoginToReview() {
    Get.snackbar(
      'review_login_required_title'.tr,
      'review_login_required_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed(Routes.LOGIN);
  }

  /// Follow/unfollow penulis karya ini.
  Future<void> toggleFollow() async {
    if (!isLoggedIn) {
      Get.snackbar(
        'follow_login_required_title'.tr,
        'follow_login_required_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(Routes.LOGIN);
      return;
    }
    if (book.authorId.isEmpty) return;

    final wasFollowing = isFollowing.value;
    final wasCount = followersCount.value;
    isFollowing.value = !wasFollowing;
    followersCount.value = wasFollowing ? wasCount - 1 : wasCount + 1;

    try {
      final ok = await _books.toggleFollow(book.authorId);
      if (!ok) {
        // Rollback on failure
        isFollowing.value = wasFollowing;
        followersCount.value = wasCount;
      }
    } catch (e) {
      isFollowing.value = wasFollowing;
      followersCount.value = wasCount;
      print('Toggle follow error: $e');
    }
  }

  /// Menambahkan ulasan dari pengguna yang sedang login. Ulasan langsung
  /// tampil di daftar (optimistic) lalu disimpan ke Supabase; jika gagal,
  /// ulasan dihapus lagi dari daftar dan user diberi tahu.
  bool submitReview({required int rating, required String comment}) {
    if (!isLoggedIn) {
      promptLoginToReview();
      return false;
    }
    final user = AuthService.to.currentUser.value;
    final displayName = user?.name ?? 'review_default_username'.tr;
    final text = comment.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'review_empty_title'.tr,
        'review_empty_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final review = ReviewModel(
      name: displayName,
      avatarColor: AppColors.accentBlue,
      rating: rating,
      timeAgo: 'review_just_now'.tr,
      comment: text,
      likes: 0,
    );
    reviews.insert(0, review);
    _saveReview(review, rating, text, displayName);
    return true;
  }

  Future<void> _saveReview(
      ReviewModel review, int rating, String comment, String userName) async {
    final ok = await _books.addReview(
      bookId: book.id,
      rating: rating,
      comment: comment,
      userName: userName,
    );
    if (!ok) {
      reviews.remove(review);
      Get.snackbar(
        'Gagal',
        'Ulasan belum tersimpan. Periksa koneksi lalu coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
