import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/main_bottom_nav.dart';
import '../../beranda/views/beranda_view.dart';
import '../../perpustakaan/views/perpustakaan_view.dart';
import '../../pencarian/views/pencarian_view.dart';
import '../../profil/views/profil_view.dart';
import '../controllers/main_nav_controller.dart';

/// Shell utama aplikasi: menampung 4 halaman tab lewat IndexedStack
/// supaya state masing-masing tab tetap terjaga saat berpindah tab.
class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      BerandaView(),
      PerpustakaanView(),
      PencarianView(),
      ProfilView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: MainBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
