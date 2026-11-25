import 'package:get/get.dart';

import '../controllers/tambah_puisi_controller.dart';

class TambahPuisiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TambahPuisiController());
  }
}