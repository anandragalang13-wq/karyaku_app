import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller halaman Profil pengguna.
class ProfilController extends GetxController {
  final AuthService _auth = AuthService.to;

  bool get isLoggedIn => _auth.isLoggedIn.value;

  /// User kosong dipakai sebagai placeholder saat belum login,
  /// supaya view tidak perlu menangani null.
  UserModel get user =>
      _auth.currentUser.value ??
      const UserModel(
        id: '',
        name: '',
        email: '',
        badge: '',
        karyaDibaca: 0,
        koleksi: 0,
        pengikut: 0,
      );

  /// Pengaturan & Bantuan bisa diakses tanpa login.
  void openSettings() => Get.toNamed(Routes.PENGATURAN_AKUN);
  void openKelolaKarya() => Get.toNamed(Routes.KELOLA_KARYA);

  void openHelp() {
    Get.defaultDialog(
      title: 'profile_help_feedback'.tr,
      middleText: 'profile_help_dialog_message'.tr,
      textConfirm: 'common_close'.tr,
      onConfirm: () => Get.back(),
    );
  }

  bool get isWriter => user.isWriter;

  /// Pembaca yang belum jadi penulis: buka form registrasi penulis
  /// terpisah (nama pena, genre, dsb). Wajib login dulu karena data
  /// penulis melekat pada akun pengguna — kalau masih guest, arahkan
  /// ke halaman login dulu.
  void goToWriterRegistration() {
    if (!isLoggedIn) {
      Get.toNamed(Routes.LOGIN);
      Get.snackbar(
        'review_login_required_title'.tr,
        'profile_writer_login_required_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(Routes.DAFTAR_PENULIS);
  }

  /// Hanya bisa diakses setelah resmi jadi penulis: buka form Tambah Karya.
  void addNewWork() => Get.toNamed(Routes.TAMBAH_KARYA);

  void logout() {
    Get.defaultDialog(
      title: 'settings_logout_confirm_title'.tr,
      middleText: 'settings_logout_confirm_message'.tr,
      textConfirm: 'settings_logout_confirm_yes'.tr,
      textCancel: 'settings_logout_confirm_cancel'.tr,
      onConfirm: () {
        _auth.logout();
        Get.back();
      },
    );
  }

  void goToLogin() => Get.toNamed(Routes.LOGIN);

  void goToRegister() => Get.toNamed(Routes.REGISTER);
}