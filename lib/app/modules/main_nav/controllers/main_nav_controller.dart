import 'package:get/get.dart';

/// Mengelola tab aktif pada bottom navigation utama (shell) aplikasi.
/// Index: 0 = Histori & Koleksi, 1 = Temukan (Pencarian), 2 = Beranda, 3 = Profil.
class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs; // default tampil di Beranda

  void changeTab(int index) => currentIndex.value = index;
}
