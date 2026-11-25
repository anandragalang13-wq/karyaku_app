import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final Rx<SortBy> sortBy = SortBy.terpopuler.obs;

  final categories = const ['Semua', 'Cerpen', 'Puisi', 'Novel'];

  final RxString searchText = ''.obs;

  SupabaseClient get _supabase => Supabase.instance.client;
  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    _subscribeToApprovedWorks();
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> loadBooks() async {
    isLoading.value = true;
    try {
      _allResults.assignAll(await Get.find<BookService>().getAllBooks());
    } finally {
      isLoading.value = false;
    }
  }

  /// Langganan real-time untuk perubahan karya approved.
  void _subscribeToApprovedWorks() {
    _realtimeChannel = _supabase
        .channel('public:books_approved_search')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'books',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'approval_status',
            value: 'approved',
          ),
          callback: (payload) {
            loadBooks();
          },
        )
        .subscribe();
  }

  List<BookModel> get results {
    var list = _allResults.where((b) {
      final matchesQuery = searchText.value.isEmpty ||
          b.title.toLowerCase().contains(searchText.value.toLowerCase()) ||
          b.author.toLowerCase().contains(searchText.value.toLowerCase());
      final matchesCategory = filterCategoryIndex.value == 0 ||
          b.category == categories[filterCategoryIndex.value];
      return matchesQuery && matchesCategory;
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
  void setSort(SortBy s) => sortBy.value = s;

  void applyFilter() => Get.back();

  void openBookDetail(BookModel book) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: book);
  }
}
