import 'package:get/get.dart';

import '../../beranda/bindings/beranda_binding.dart';
import '../../perpustakaan/bindings/perpustakaan_binding.dart';
import '../../pencarian/bindings/pencarian_binding.dart';
import '../../profil/bindings/profil_binding.dart';
import '../controllers/main_nav_controller.dart';

/// Binding gabungan: menyiapkan MainNavController sekaligus semua controller
/// dari 4 tab agar tersedia begitu shell dibuka.
class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController());
    BerandaBinding().dependencies();
    PerpustakaanBinding().dependencies();
    PencarianBinding().dependencies();
    ProfilBinding().dependencies();
  }
}
