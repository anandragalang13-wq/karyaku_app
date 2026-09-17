import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';

enum SortBy { terpopuler, terbaru, ratingTertinggi }

/// Controller halaman Pencarian (Temukan): kata kunci pencarian dan
/// filter & pengurutan lewat bottom sheet "Filter & Urutkan".
class PencarianController extends GetxController {
  final List<BookModel> _allResults = MockData.searchResults;

  // State filter (nilai sementara di bottom sheet, diterapkan saat "Terapkan Filter")
  final RxInt filterCategoryIndex = 0.obs; // 0 Semua,1 Cerpen,2 Puisi,3 Novel
  final RxBool statusSelesai = false.obs;
  final RxBool statusOngoing = true.obs;
  final Rx<SortBy> sortBy = SortBy.terpopuler.obs;

  final categories = const ['Semua', 'Cerpen', 'Puisi', 'Novel'];

  final RxString searchText = ''.obs;

  List<BookModel> get results {
    var list = _allResults.where((b) {
      final matchesQuery = searchText.value.isEmpty ||
          b.title.toLowerCase().contains(searchText.value.toLowerCase()) ||
          b.author.toLowerCase().contains(searchText.value.toLowerCase());
      final matchesCategory = filterCategoryIndex.value == 0 ||
          b.category == categories[filterCategoryIndex.value];
      final matchesStatus = (statusSelesai.value && b.status == 'Selesai') ||
          (statusOngoing.value && b.status == 'Ongoing') ||
          (!statusSelesai.value && !statusOngoing.value);
      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();

    switch (sortBy.value) {
      case SortBy.terpopuler:
        list.sort((a, b) => b.views.compareTo(a.views));
        break;
      case SortBy.terbaru:
        break; // urutan asli dianggap terbaru pada data mock
      case SortBy.ratingTertinggi:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  void setCategory(int i) => filterCategoryIndex.value = i;
  void toggleSelesai(bool? v) => statusSelesai.value = v ?? false;
  void toggleOngoing(bool? v) => statusOngoing.value = v ?? false;
  void setSort(SortBy s) => sortBy.value = s;

  void applyFilter() => Get.back();

  void openBookDetail(BookModel book) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: book);
  }
}
