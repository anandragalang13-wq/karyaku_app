import 'package:get/get.dart';

import '../data/models/user_model.dart';

/// Menyimpan status autentikasi pengguna secara global.
/// Di-inject sekali di main.dart (Get.put(AuthService(), permanent: true))
/// sehingga bisa diakses dari mana saja lewat AuthService.to.
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Dipanggil setelah proses login/register berhasil.
  void login(UserModel user) {
    currentUser.value = user;
    isLoggedIn.value = true;
  }

  void logout() {
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  /// Menandai pengguna yang sedang login sebagai penulis, dengan data
  /// hasil pengisian form registrasi penulis (nama pena & genre).
  void becomeWriter({required String penName, List<String> favoriteGenres = const []}) {
    final user = currentUser.value;
    if (user == null) return;
    currentUser.value = user.copyWith(
      isWriter: true,
      penName: penName,
      favoriteGenres: favoriteGenres,
    );
  }
}