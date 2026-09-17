import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';

/// Controller gabungan untuk halaman Histori Baca & Koleksi Saya,
/// yang di desain berbagi tab bar & filter kategori yang sama.
class PerpustakaanController extends GetxController {
  final RxInt tabIndex = 0.obs; // 0 = Histori, 1 = Koleksi
  final RxInt categoryIndex = 0.obs; // 0=Semua,1=Novel,2=Puisi,3=Cerpen

  final categories = const ['Semua', 'Novel', 'Puisi', 'Cerpen'];

  final List<BookModel> _history = MockData.historyBooks;
  final List<BookModel> _collection = MockData.collectionBooks;

  List<BookModel> get filteredHistory => _filter(_history);
  List<BookModel> get filteredCollection => _filter(_collection);

  List<BookModel> _filter(List<BookModel> source) {
    if (categoryIndex.value == 0) return source;
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
