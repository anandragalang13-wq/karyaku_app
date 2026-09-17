import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/book_model.dart';
import '../data/models/book_model_extension.dart';  // ← TAMBAH INI
import '../data/models/review_model.dart';
import '../data/models/review_model_extension.dart';  // ← TAMBAH INI
import '../config/supabase_config.dart';

class BookService extends GetxService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Mengambil buku terpopuler (diurutkan berdasarkan jumlah views),
  /// dipakai oleh BerandaController untuk mengisi banner & grid utama.
  Future<List<BookModel>> getPopularBooks({int limit = 10}) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .order('views_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(e))
          .toList();
    } catch (e) {
      print('Get popular books error: $e');
      return [];
    }
  }

  /// Mencari buku berdasarkan kata kunci judul/penulis dan/atau kategori.
  /// `category` bernilai 'Semua' berarti tidak ada filter kategori.
  Future<List<BookModel>> searchBooks({
    String query = '',
    String category = 'Semua',
  }) async {
    try {
      var builder = supabase.from(SupabaseConfig.booksTable).select();

      if (query.trim().isNotEmpty) {
        builder = builder.ilike('title', '%${query.trim()}%');
      }
      if (category.isNotEmpty && category != 'Semua') {
        builder = builder.eq('category', category);
      }

      final response =
          await builder.order('views_count', ascending: false);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(e))
          .toList();
    } catch (e) {
      print('Search books error: $e');
      return [];
    }
  }

  Future<List<BookModel>> getAllBooks() async {
    try {
      final response = await supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => BookModelExtension.fromJson(e))  // ← UBAH INI
          .toList();
    } catch (e) {
      print('Get books error: $e');
      return [];
    }
  }

  Future<List<ReviewModel>> getReviews(String bookId) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.reviewsTable)
          .select()
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ReviewModelExtension.fromJson(e))  // ← UBAH INI
          .toList();
    } catch (e) {
      print('Get reviews error: $e');
      return [];
    }
  }
}