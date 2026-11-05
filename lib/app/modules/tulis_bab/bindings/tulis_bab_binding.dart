import 'package:get/get.dart';

import '../controllers/tulis_bab_controller.dart';

class TulisBabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TulisBabController>(() => TulisBabController());
  }
}
