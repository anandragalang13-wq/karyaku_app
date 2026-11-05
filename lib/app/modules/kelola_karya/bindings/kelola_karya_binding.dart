import 'package:get/get.dart';

import '../controllers/kelola_karya_controller.dart';

class KelolaKaryaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaKaryaController>(() => KelolaKaryaController());
  }
}
