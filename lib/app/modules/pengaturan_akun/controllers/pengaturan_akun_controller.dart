import 'package:get/get.dart';
import '../../../services/locale_service.dart';
import '../../../services/reading_prefs_service.dart';
import '../../../theme/app_theme.dart';

/// Controller halaman Pengaturan & Akun.
class PengaturanAkunController extends GetxController {
  final RxBool notifEnabled = true.obs;
  final RxBool wifiOnlyDownload = false.obs;
  final String cacheSize = '45 MB';

  final LocaleService _localeService = Get.find<LocaleService>();
  final ReadingPrefsService _readingPrefs = Get.find<ReadingPrefsService>();

  /// Bahasa yang sedang aktif, dipakai dropdown di halaman Pengaturan.
  Rx<AppLanguage> get selectedLanguage => _localeService.currentLanguage;

  /// Warna background & ukuran font baca: menunjuk ke preferensi yang sama
  /// dengan panel Pengaturan Buku di Reader, dan tersimpan di perangkat.
  Rx<ReaderTheme> get selectedTheme => _readingPrefs.theme;
  RxDouble get fontSize => _readingPrefs.fontSize;

  void toggleNotif(bool v) => notifEnabled.value = v;
  void toggleWifiOnly(bool v) => wifiOnlyDownload.value = v;

  /// Ganti warna background halaman baca (langsung disimpan).
  void selectTheme(ReaderTheme t) => _readingPrefs.setTheme(t);

  /// Ganti ukuran font halaman baca (langsung disimpan).
  void changeFontSize(double v) => _readingPrefs.setFontSize(v);

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