import 'package:get/get.dart';

import '../controllers/daftar_penulis_controller.dart';

class DaftarPenulisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarPenulisController>(
      () => DaftarPenulisController(),
    );
  }
}
