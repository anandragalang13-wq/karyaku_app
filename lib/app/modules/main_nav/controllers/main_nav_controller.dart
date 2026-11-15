import 'package:get/get.dart';

import '../../perpustakaan/controllers/perpustakaan_controller.dart';

/// Mengelola tab aktif pada bottom navigation utama (shell) aplikasi.
/// Index: 0 = Beranda, 1 = Perpustakaan, 2 = Pencarian, 3 = Profil.
class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs; // default tampil di Beranda

  void changeTab(int index) {
    currentIndex.value = index;
    // Kembali ke tab Perpustakaan → muat ulang riwayat/koleksi dari
    // database supaya hasil membaca terbaru langsung terlihat.
    if (index == 1 && Get.isRegistered<PerpustakaanController>()) {
      Get.find<PerpustakaanController>().loadLibrary();
    }
  }
}
