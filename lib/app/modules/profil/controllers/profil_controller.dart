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

  void openSettings() => Get.toNamed(Routes.PENGATURAN_AKUN);
  void openStatistik() => Get.toNamed(Routes.STATISTIK);

  bool get isWriter => user.isWriter;

  /// Pembaca yang belum jadi penulis: buka form registrasi penulis
  /// terpisah (nama pena, genre, dsb).
  void goToWriterRegistration() => Get.toNamed(Routes.DAFTAR_PENULIS);

  /// Hanya bisa diakses setelah resmi jadi penulis: buka form Tambah Karya.
  void addNewWork() => Get.toNamed(Routes.TAMBAH_KARYA);

  void logout() {
    Get.defaultDialog(
      title: 'Keluar Akun',
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      textConfirm: 'Keluar',
      textCancel: 'Batal',
      onConfirm: () {
        _auth.logout();
        Get.back();
      },
    );
  }

  void goToLogin() => Get.toNamed(Routes.LOGIN);

  void goToRegister() => Get.toNamed(Routes.REGISTER);
}