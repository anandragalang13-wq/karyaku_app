import 'package:get/get.dart';
import '../../../theme/app_theme.dart';

/// Controller halaman Pengaturan & Akun.
class PengaturanAkunController extends GetxController {
  final RxBool notifEnabled = true.obs;
  final RxBool wifiOnlyDownload = false.obs;
  final Rx<ReaderTheme> selectedTheme = ReaderTheme.light.obs;
  final RxDouble fontSize = 16.0.obs;
  final String cacheSize = '45 MB';

  void toggleNotif(bool v) => notifEnabled.value = v;
  void toggleWifiOnly(bool v) => wifiOnlyDownload.value = v;
  void selectTheme(ReaderTheme t) => selectedTheme.value = t;
  void changeFontSize(double v) => fontSize.value = v;

  void clearCache() {
    Get.snackbar('Cache Dibersihkan', 'Cache data berhasil dihapus.',
        snackPosition: SnackPosition.BOTTOM);
  }

  void logout() {
    Get.defaultDialog(
      title: 'Keluar Akun',
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      textConfirm: 'Keluar',
      textCancel: 'Batal',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () => Get.back(),
    );
  }
}
