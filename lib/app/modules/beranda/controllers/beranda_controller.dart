import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/work_model.dart';
import '../../../data/models/work_model_exension.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

/// Controller untuk halaman Beranda: karya rekomendasi, kategori,
/// dan daftar karya terpopuler (yang sudah approved) dari Supabase.
class BerandaController extends GetxController {
  // State Observables
  final Rx<WorkModel?> featuredWork = Rx<WorkModel?>(null);
  final RxList<WorkModel> allWorks = <WorkModel>[].obs;
  final RxList<WorkModel> filteredWorks = <WorkModel>[].obs;

  final RxList<String> categories = <String>[
    'Semua',
    'Novel',
    'Puisi',
    'Cerpen'
  ].obs;

  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  BookService get _books => Get.find<BookService>();
  SupabaseClient get _supabase => Supabase.instance.client;
  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    loadBerandaData();
    _subscribeToApprovedWorks();
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  /// Memuat semua karya approved dari Supabase.
  Future<void> loadBerandaData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final works = await _books.getApprovedWorks(); // sudah urut views
      debugPrint('Beranda: ${works.length} karya approved dimuat');
      for (final w in works) {
        debugPrint(
            '  - ${w.title} | type: ${w.type} | tags: ${w.tags} | author: ${w.authorName}');
      }
      allWorks.assignAll(works);
      _applyCategory();
    } catch (e, st) {
      errorMessage.value = 'Gagal memuat karya: $e';
      debugPrint('Error loading beranda data: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  /// Langganan real-time untuk perubahan karya approved.
  /// Hanya reload saat ada karya BARU yang di-approve (INSERT).
  /// Hindari UPDATE (views) supaya tidak reload terus-menerus.
  void _subscribeToApprovedWorks() {
    _realtimeChannel = _supabase
        .channel('public:books_approved')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'books',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'approval_status',
            value: 'approved',
          ),
          callback: (payload) {
            // Hanya refresh saat ada karya baru yang di-approve
            loadBerandaData();
          },
        )
        .subscribe();
  }

  /// Filter karya berdasarkan kategori/tipe (dari data yang sudah dimuat).
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    _applyCategory();
  }

  void _applyCategory() {
    final selected = categories[selectedCategoryIndex.value];
    var list = [...allWorks];

    if (selected != 'Semua') {
      final type = _getWorkTypeFromString(selected);
      list = list.where((w) => w.type == type).toList();
    }
    list.sort((a, b) => b.views.compareTo(a.views));

    filteredWorks.assignAll(list);
    featuredWork.value = list.isNotEmpty ? list.first : null;
  }

  WorkType _getWorkTypeFromString(String category) {
    switch (category.toLowerCase()) {
      case 'puisi':
        return WorkType.puisi;
      case 'cerpen':
        return WorkType.cerpen;
      default:
        return WorkType.novel;
    }
  }

  List<WorkModel> getTopRatedWorks({int limit = 5}) {
    final works = [...filteredWorks];
    works.sort((a, b) => b.rating.compareTo(a.rating));
    return works.take(limit).toList();
  }

  List<WorkModel> getMostViewedWorks({int limit = 5}) {
    final works = [...filteredWorks];
    works.sort((a, b) => b.views.compareTo(a.views));
    return works.take(limit).toList();
  }

  /// Navigasi ke detail. DetailBukuController bekerja dengan BookModel,
  /// jadi WorkModel dikonversi dulu (sebelumnya argumen WorkModel diabaikan
  /// dan halaman detail menampilkan buku contoh).
  void openWorkDetail(WorkModel work) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: work.toBookModel());
  }

  void navigateToCreateWork() {
    Get.toNamed(Routes.TAMBAH_KARYA);
  }

  /// Membuka halaman Temukan (Pencarian) dari tombol search di Beranda.
  ///
  /// Beranda berada di dalam shell [MainNavController], jadi cukup pindah
  /// tab — user langsung bisa mengetik kata kunci di kolom pencarian.
  void openSearch() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2);
    }
  }
}