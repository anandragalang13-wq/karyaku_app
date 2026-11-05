import 'package:get/get.dart';

import '../controllers/progres_cerita_controller.dart';

class ProgresCeritaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgresCeritaController>(() => ProgresCeritaController());
  }
}
