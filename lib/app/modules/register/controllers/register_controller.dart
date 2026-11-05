import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final SupabaseClient supabase = Supabase.instance.client;

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.toggle();

  void toggleAgreeToTerms(bool? v) =>
      agreeToTerms.value = v ?? false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    // =========================
    // VALIDASI
    // =========================

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
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
      errorText.value =
          'Anda harus menyetujui Syarat & Ketentuan.';
      return;
    }

    errorText.value = '';
    isLoading.value = true;

    try {
      // =========================
      // REGISTER KE SUPABASE
      // =========================

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      final user = response.user;

      if (user == null) {
        errorText.value =
            'Pendaftaran gagal. Silakan coba lagi.';
        return;
      }

      // =========================
      // BERHASIL
      // =========================

      Get.snackbar(
        'Berhasil',
        'Akun berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Kalau email confirmation aktif,
      // user harus verifikasi email terlebih dahulu.
      if (response.session == null) {
        Get.snackbar(
          'Verifikasi Email',
          'Silakan cek email untuk melakukan verifikasi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // Sinkronkan status login & profil supaya langsung terbaca di app.
      if (response.session != null) {
        await AuthService.to.refreshSession();
      }

      Get.offAllNamed(Routes.MAIN);

    } on AuthException catch (e) {
      errorText.value = e.message;

      Get.snackbar(
        'Pendaftaran Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      errorText.value =
          'Terjadi kesalahan: $e';

      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mendaftar.',
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {
      isLoading.value = false;
    }
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