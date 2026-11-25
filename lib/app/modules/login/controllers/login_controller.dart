import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller halaman Login KARYAKU.
class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorText = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.toggle();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Reset error
    errorText.value = '';

    // Validasi sederhana
    if (email.isEmpty) {
      errorText.value = 'Email harus diisi.';
      return;
    }

    if (password.isEmpty) {
      errorText.value = 'Kata sandi harus diisi.';
      return;
    }

    try {
      isLoading.value = true;

      // Login ke Supabase
      await AuthService.to.login(
        email: email,
        password: password,
      );

      // Kalau login Supabase berhasil
      if (AuthService.to.isLoggedIn.value) {
        // Langsung masuk ke halaman utama
        Get.offAllNamed(Routes.MAIN);
      } else {
        errorText.value =
            AuthService.to.errorMessage.value.isNotEmpty
                ? AuthService.to.errorMessage.value
                : 'Email atau kata sandi salah.';
      }
    } catch (e) {
      errorText.value = 'Terjadi kesalahan saat login.';
      print('Login Controller Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}