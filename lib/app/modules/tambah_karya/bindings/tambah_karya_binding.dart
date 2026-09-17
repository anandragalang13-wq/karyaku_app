import 'package:get/get.dart';
import '../controllers/tambah_karya_controller.dart';
class TambahKaryaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahKaryaController>(() => TambahKaryaController());
  }
}
