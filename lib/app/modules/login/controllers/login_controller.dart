import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller halaman Login KARYAKU.
class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorText = ''.obs;

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorText.value = 'Email dan kata sandi wajib diisi.';
      return;
    }
    errorText.value = '';
    isLoading.value = true;

    // Simulasi proses autentikasi ke backend.
    await Future.delayed(const Duration(milliseconds: 900));

    isLoading.value = false;

    // Simulasi user berhasil masuk (belum ada backend asli).
    AuthService.to.login(MockData.currentUser);
    Get.offAllNamed(Routes.MAIN);
  }

  void loginWithGoogle() {
    Get.snackbar('Masuk dengan Google', 'Menghubungkan ke akun Google...',
        snackPosition: SnackPosition.BOTTOM);
  }

  void forgotPassword() {
    Get.snackbar('Lupa Kata Sandi', 'Tautan reset kata sandi akan dikirim ke email Anda.',
        snackPosition: SnackPosition.BOTTOM);
  }

  void goToRegister() => Get.toNamed(Routes.REGISTER);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}