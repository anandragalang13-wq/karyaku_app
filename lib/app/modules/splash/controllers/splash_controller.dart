import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  late RxDouble logoOpacity;
  late RxDouble loaderOpacity;

  @override
  void onInit() {
    super.onInit();
    logoOpacity = 0.0.obs;
    loaderOpacity = 0.0.obs;

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Animasi fade-in logo
    await Future.delayed(const Duration(milliseconds: 300));
    logoOpacity.value = 1.0;

    // Tampilkan loader
    await Future.delayed(const Duration(milliseconds: 500));
    loaderOpacity.value = 1.0;

    // Simulasi loading (bisa diganti dengan actual initialization)
    await Future.delayed(const Duration(seconds: 5));

    // Navigate ke halaman utama (beranda)
    Get.offNamed(Routes.MAIN);
  }
}
