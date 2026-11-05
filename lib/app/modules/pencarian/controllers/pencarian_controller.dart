import 'package:get/get.dart';

import '../../../data/models/book_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';

enum SortBy { terpopuler, terbaru, ratingTertinggi }

/// Controller halaman Pencarian (Temukan): kata kunci pencarian dan
/// filter & pengurutan lewat bottom sheet "Filter & Urutkan".
class PencarianController extends GetxController {
  // Sumber buku: karya approved dari Supabase (urut terbaru dari server).
  final RxList<BookModel> _allResults = <BookModel>[].obs;
  final RxBool isLoading = false.obs;

  // State filter (nilai sementara di bottom sheet, diterapkan saat "Terapkan Filter")
  final RxInt filterCategoryIndex = 0.obs; // 0 Semua,1 Cerpen,2 Puisi,3 Novel
  final RxBool statusSelesai = false.obs;
  final RxBool statusOngoing = true.obs;
  final Rx<SortBy> sortBy = SortBy.terpopuler.obs;

  final categories = const ['Semua', 'Cerpen', 'Puisi', 'Novel'];

  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  Future<void> loadBooks() async {
    isLoading.value = true;
    try {
      _allResults.assignAll(await Get.find<BookService>().getAllBooks());
    } finally {
      isLoading.value = false;
    }
  }

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
        break; // urutan dari server: created_at terbaru dulu
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
