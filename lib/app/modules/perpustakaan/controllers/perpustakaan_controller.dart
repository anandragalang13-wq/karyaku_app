import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';

/// Controller gabungan untuk halaman Histori Baca & Koleksi Saya,
/// yang di desain berbagi tab bar & filter kategori yang sama.
///
/// CATATAN: tabel histori baca & koleksi per-user belum ada di database,
/// jadi kedua tab sementara menampilkan karya approved dari Supabase
/// (sama seperti perilaku data mock sebelumnya).
class PerpustakaanController extends GetxController {
  final RxInt tabIndex = 0.obs; // 0 = Histori, 1 = Koleksi
  final RxInt categoryIndex = 0.obs; // 0=Semua,1=Novel,2=Puisi,3=Cerpen

  final categories = const ['Semua', 'Novel', 'Puisi', 'Cerpen'];

  final RxList<BookModel> _history = <BookModel>[].obs;
  final RxList<BookModel> _collection = <BookModel>[].obs;
  final RxBool isLoading = false.obs;

  List<BookModel> get filteredHistory => _filter(_history);
  List<BookModel> get filteredCollection => _filter(_collection);

  @override
  void onInit() {
    super.onInit();
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    isLoading.value = true;
    try {
      final books = await Get.find<BookService>().getAllBooks();
      _history.assignAll(books);
      _collection.assignAll(books);
    } finally {
      isLoading.value = false;
    }
  }

  List<BookModel> _filter(List<BookModel> source) {
    if (categoryIndex.value == 0) return source.toList();
    final cat = categories[categoryIndex.value];
    return source.where((b) => b.category == cat).toList();
  }

  void changeTab(int i) => tabIndex.value = i;
  void changeCategory(int i) => categoryIndex.value = i;

  void openBookDetail(BookModel book) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: book);
  }

  void addCollection() {
    Get.snackbar('Tambah Koleksi', 'Fitur tambah koleksi baru akan segera hadir.',
        snackPosition: SnackPosition.BOTTOM);
  }
}
