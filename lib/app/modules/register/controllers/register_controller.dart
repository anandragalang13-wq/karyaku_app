import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller halaman Daftar (Register) akun baru KARYAKU.
class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorText = ''.obs;

  void togglePasswordVisibility() => isPasswordHidden.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.toggle();
  void toggleAgreeToTerms(bool? v) => agreeToTerms.value = v ?? false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      errorText.value = 'Semua kolom wajib diisi.';
      return;
    }
    if (password != confirm) {
      errorText.value = 'Konfirmasi kata sandi tidak cocok.';
      return;
    }
    if (password.length < 6) {
      errorText.value = 'Kata sandi minimal 6 karakter.';
      return;
    }
    if (!agreeToTerms.value) {
      errorText.value = 'Anda harus menyetujui Syarat & Ketentuan.';
      return;
    }

    errorText.value = '';
    isLoading.value = true;

    // Simulasi proses pendaftaran ke backend.
    await Future.delayed(const Duration(milliseconds: 900));

    isLoading.value = false;

    // Simulasi akun baru langsung masuk (belum ada backend asli).
    AuthService.to.login(UserModel(
      id: email,
      name: name,
      email: email,
      badge: 'Pembaca Baru',
      karyaDibaca: 0,
      koleksi: 0,
      pengikut: 0,
    ));
    Get.offAllNamed(Routes.MAIN);
  }

  void goToLogin() => Get.back();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}