import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karyaku_app/app/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_routes.dart';
import '../../../services/supabase_auth_service.dart';

class EmailVerificationController extends GetxController {
  final SupabaseAuthService _auth = SupabaseAuthService.to;

  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;
  final RxBool verificationSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Cek apakah ada parameter verifikasi dari URL
    _handleVerificationFromUrl();
  }

  void _handleVerificationFromUrl() {
    // Get parameter dari route arguments
    final args = Get.arguments;
    if (args is Map && args['type'] == 'recovery') {
      // User klik link reset password dari email
      message.value = 'email_verification_reset_password'.tr;
    } else if (args is Map && args['type'] == 'signup') {
      // User klik link verifikasi email dari signup
      message.value = 'email_verification_success'.tr;
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      Get.snackbar('error'.tr, 'Masukkan email yang valid',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      await _auth.supabase.auth.resend(
        type: OtpType.signup,
        email: trimmed,
      );

      verificationSent.value = true;
      Get.snackbar(
        'email_verification_sent_title'.tr,
        'email_verification_sent_message'.trArgs([trimmed]),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'email_verification_failed_title'.tr,
        'email_verification_failed_message'.trArgs([e.toString()]),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      print('Resend verification error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.offAllNamed(Routes.LOGIN);
}