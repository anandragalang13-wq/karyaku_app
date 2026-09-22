import 'package:get/get.dart';
import '../../../data/models/work_model.dart';
import '../../../data/mock_works_data.dart' show MockWorksData;
import '../../../routes/app_routes.dart';

/// Controller untuk halaman Beranda: karya rekomendasi, kategori,
/// dan daftar karya terpopuler (yang sudah approved)
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

  @override
  void onInit() {
    super.onInit();
    loadBerandaData();
  }

  /// Memuat semua data karya yang sudah approved dari MockWorksData
  Future<void> loadBerandaData() async {
    try {
      isLoading.value = true;

      // Ambil karya yang sudah approved (untuk public view)
      final approvedWorks = MockWorksData.getApprovedWorks();
      
      // Sort by views (most popular first)
      approvedWorks.sort((a, b) => b.views.compareTo(a.views));
      
      allWorks.assignAll(approvedWorks);
      filteredWorks.assignAll(approvedWorks);

      // Set featured work (karya dengan views terbanyak)
      if (approvedWorks.isNotEmpty) {
        featuredWork.value = approvedWorks.first;
      }

      // Delay untuk demo loading state
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error loading beranda data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter karya berdasarkan kategori/tipe
  void selectCategory(int index) async {
    try {
      selectedCategoryIndex.value = index;
      isLoading.value = true;

      final selectedCategory = categories[index];
      
      // Reset ke semua karya approved
      var filtered = MockWorksData.getApprovedWorks();

      // Filter berdasarkan kategori jika bukan "Semua"
      if (selectedCategory != 'Semua') {
        final workType = _getWorkTypeFromString(selectedCategory);
        filtered = filtered.where((work) => work.type == workType).toList();
      }

      // Sort by views
      filtered.sort((a, b) => b.views.compareTo(a.views));
      
      filteredWorks.assignAll(filtered);

      // Update featured work dari hasil filter
      if (filtered.isNotEmpty) {
        featuredWork.value = filtered.first;
      }

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Error filtering works by category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert string kategori menjadi WorkType enum
  WorkType _getWorkTypeFromString(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return WorkType.novel;
      case 'puisi':
        return WorkType.puisi;
      case 'cerpen':
        return WorkType.cerpen;
      default:
        return WorkType.novel;
    }
  }

  /// Ambil karya dengan rating tertinggi
  List<WorkModel> getTopRatedWorks({int limit = 5}) {
    final works = [...filteredWorks];
    works.sort((a, b) => b.rating.compareTo(a.rating));
    return works.take(limit).toList();
  }

  /// Ambil karya dengan views terbanyak
  List<WorkModel> getMostViewedWorks({int limit = 5}) {
    final works = [...filteredWorks];
    works.sort((a, b) => b.views.compareTo(a.views));
    return works.take(limit).toList();
  }

  /// Navigasi ke halaman detail karya
  void openWorkDetail(WorkModel work) {
    Get.toNamed(Routes.DETAIL_BUKU, arguments: work);
  }

  /// Navigasi ke halaman membuat karya baru
  void navigateToCreateWork() {
    Get.toNamed(Routes.TAMBAH_KARYA);
  }
}