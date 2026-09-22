import 'package:get/get.dart';
import '../../../services/locale_service.dart';
import '../../../theme/app_theme.dart';

/// Controller halaman Pengaturan & Akun.
class PengaturanAkunController extends GetxController {
  final RxBool notifEnabled = true.obs;
  final RxBool wifiOnlyDownload = false.obs;
  final Rx<ReaderTheme> selectedTheme = ReaderTheme.light.obs;
  final RxDouble fontSize = 16.0.obs;
  final String cacheSize = '45 MB';

  final LocaleService _localeService = Get.find<LocaleService>();

  /// Bahasa yang sedang aktif, dipakai dropdown di halaman Pengaturan.
  Rx<AppLanguage> get selectedLanguage => _localeService.currentLanguage;

  void toggleNotif(bool v) => notifEnabled.value = v;
  void toggleWifiOnly(bool v) => wifiOnlyDownload.value = v;
  void selectTheme(ReaderTheme t) => selectedTheme.value = t;
  void changeFontSize(double v) => fontSize.value = v;

  /// Mengubah bahasa aplikasi. Perubahan langsung berlaku di seluruh
  /// halaman (lewat Get.updateLocale) dan disimpan untuk sesi berikutnya.
  Future<void> changeLanguage(AppLanguage language) {
    return _localeService.changeLanguage(language);
  }

  void clearCache() {
    Get.snackbar(
      'settings_cache_cleared_title'.tr,
      'settings_cache_cleared_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'settings_logout_confirm_title'.tr,
      middleText: 'settings_logout_confirm_message'.tr,
      textConfirm: 'settings_logout_confirm_yes'.tr,
      textCancel: 'settings_logout_confirm_cancel'.tr,
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () => Get.back(),
    );
  }
}