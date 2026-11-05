import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chapter_content.dart';
import '../../../data/models/work_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';

/// Controller halaman "Kelola Karya" (pengganti halaman Statistik).
///
/// Berisi dua bagian utama:
/// 1. Karya yang masih draft/ditolak → bisa dilanjutkan dengan menulis bab baru.
/// 2. Statistik setiap buku milik penulis (pembaca, rating, bab, ulasan).
class KelolaKaryaController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<WorkModel> works = <WorkModel>[].obs;
  final RxMap<String, int> reviewCounts = <String, int>{}.obs;

  bool get isLoggedIn => AuthService.to.isLoggedIn.value;

  BookService get _books => Get.find<BookService>();

  Worker? _loginWorker;

  @override
  void onInit() {
    super.onInit();
    if (isLoggedIn) loadData();

    // Saat status login berubah (mis. user masuk dari halaman ini), data
    // karya langsung dimuat ulang supaya layar tidak kosong.
    _loginWorker = ever<bool>(AuthService.to.isLoggedIn, (loggedIn) {
      if (loggedIn) {
        loadData();
      } else {
        works.clear();
        reviewCounts.clear();
        errorMessage.value = '';
      }
    });
  }

  @override
  void onClose() {
    _loginWorker?.dispose();
    super.onClose();
  }

  // ------------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------------

  Future<void> loadData() async {
    if (!isLoggedIn) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final myWorks = await _books.getMyWorks();
      works.assignAll(myWorks);

      final counts =
          await _books.countReviewsByBook(myWorks.map((w) => w.id).toList());
      reviewCounts.assignAll(counts);
    } catch (e) {
      errorMessage.value = 'Gagal memuat karya: $e';
      print('Error loading kelola karya: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------------
  // TURUNAN DATA
  // ------------------------------------------------------------------

  /// Karya yang masih boleh ditulis lanjut: draft maupun yang ditolak admin.
  List<WorkModel> get draftWorks => works.where((w) => w.canEdit()).toList();

  int get totalViews => works.fold<int>(0, (sum, w) => sum + w.views);

  double get averageRating {
    final rated = works.where((w) => w.rating > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.fold<double>(0, (sum, w) => sum + w.rating) / rated.length;
  }

  int chapterCountOf(WorkModel work) => ChapterContent.countOf(
        content: work.content,
        chapterCount: work.chapterCount,
      );

  int reviewCountOf(WorkModel work) => reviewCounts[work.id] ?? 0;

  /// Karya dengan pembaca terbanyak (maksimal 5) untuk grafik batang.
  List<WorkModel> get chartWorks {
    final list = works.where((w) => w.views > 0).toList()
      ..sort((a, b) => b.views.compareTo(a.views));
    return list.take(5).toList();
  }

  /// Daftar statistik karya: yang sudah terbit lebih dulu, lalu paling banyak
  /// pembaca.
  List<WorkModel> get statWorks {
    final list = [...works];
    list.sort((a, b) {
      final rank = _statusRank(a).compareTo(_statusRank(b));
      if (rank != 0) return rank;
      return b.views.compareTo(a.views);
    });
    return list;
  }

  int _statusRank(WorkModel work) {
    switch (work.approvalStatus) {
      case ApprovalStatus.approved:
        return 0;
      case ApprovalStatus.pending:
        return 1;
      case ApprovalStatus.rejected:
        return 2;
      case ApprovalStatus.draft:
        return 3;
    }
  }

  // ------------------------------------------------------------------
  // AKSI
  // ------------------------------------------------------------------

  /// Membuka halaman "Progres Cerita" lebih dulu (bukan langsung editor bab
  /// kosong) supaya penulis meninjau progres isi bab sebelumnya, lalu bisa
  /// menambah bab baru lewat tombol di halaman tersebut. Data di-refresh
  /// kembali setelah halaman progres ditutup (baik setelah menyimpan bab
  /// maupun hanya meninjau).
  Future<void> openStoryProgress(WorkModel work) async {
    await Get.toNamed(Routes.PROGRES_CERITA, arguments: work);
    await loadData();
  }

  /// Konfirmasi lalu menghapus karya milik penulis sendiri.
  ///
  /// Dihapus dari daftar lokal setelah backend mengonfirmasi; kebijakan RLS
  /// `books_delete_own` memastikan penulis hanya bisa menghapus karyanya.
  Future<void> confirmDeleteWork(WorkModel work) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('manage_works_delete_title'.tr),
        content: Text(
          'manage_works_delete_message'.trArgs([work.title]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('manage_works_delete_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'manage_works_delete_confirm'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await _books.deleteWork(work.id);
      works.removeWhere((w) => w.id == work.id);
      reviewCounts.remove(work.id);
      Get.snackbar(
        'manage_works_delete_title'.tr,
        'manage_works_delete_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'manage_works_delete_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openAddWork() => Get.toNamed(Routes.TAMBAH_KARYA);

  void goToLogin() => Get.toNamed(Routes.LOGIN);

  /// Angka ringkas untuk statistik: 245000 → "245k", 1200 → "1.2k".
  static String formatCount(num value) {
    final v = value.toDouble();
    if (v >= 1000000) return '${_trim(v / 1000000)}M';
    if (v >= 1000) return '${_trim(v / 1000)}k';
    return _trim(v);
  }

  static String _trim(double value) {
    final rounded =
        value >= 100 ? value.roundToDouble() : (value * 10).roundToDouble() / 10;
    return rounded % 1 == 0 ? rounded.toInt().toString() : rounded.toString();
  }
}
