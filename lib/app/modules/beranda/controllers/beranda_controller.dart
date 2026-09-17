import 'package:get/get.dart';
import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';

/// Controller untuk halaman Beranda: karya rekomendasi, tag/kategori,
/// dan daftar karya terpopuler dari Supabase.
class BerandaController extends GetxController {
  final BookService _bookService = Get.find<BookService>();

  // State Observables
  final Rx<BookModel?> featuredBook = Rx<BookModel?>(null);
  final RxList<BookModel> popularBooks = <BookModel>[].obs;
  final RxList<String> tags = <String>['Semua', 'Novel', 'Puisi', 'Cerpen'].obs;
  
  final RxInt selectedTagIndex = 0.obs;
  final RxInt bannerStep = 1.obs; // Indikator "1. Beranda 2. Karyaku 3. Komunitas"
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBerandaData();
  }

  /// Memuat semua data awal untuk halaman Beranda dari Supabase
  Future<void> loadBerandaData() async {
    try {
      isLoading.value = true;
      
      // Ambil buku populer dari Supabase
      final books = await _bookService.getPopularBooks(limit: 10);
      popularBooks.assignAll(books);

      // Set featured book (ambil buku pertama dari list jika ada)
      if (books.isNotEmpty) {
        featuredBook.value = books.first;
      }
    } catch (e) {
      print('Error loading beranda data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Memilih tag/kategori dan memfilter daftar buku
  void selectTag(int index) async {
    selectedTagIndex.value = index;
    final selectedCategory = tags[index];

    try {
      isLoading.value = true;
      // Filter buku berdasarkan kategori yang dipilih
      final filteredBooks = await _bookService.searchBooks(
        query: '',
        category: selectedCategory,
      );
      popularBooks.assignAll(filteredBooks);
    } catch (e) {
      print('Error filtering books by tag: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigasi ke halaman detail buku dengan membawa objek book
  void openBookDetail(BookModel book) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: book);
  }
}