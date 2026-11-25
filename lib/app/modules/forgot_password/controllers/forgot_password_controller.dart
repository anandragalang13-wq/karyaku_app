import 'package:get/get.dart';

import '../../../services/supabase_auth_service.dart';

class ForgotPasswordController extends GetxController {
  final SupabaseAuthService _auth = SupabaseAuthService.to;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool emailSent = false.obs;

  Future<void> sendResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      errorMessage.value = 'Masukkan email yang valid';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.supabase.auth.resetPasswordForEmail(trimmed);

      emailSent.value = true;
    } catch (e) {
      errorMessage.value = 'Gagal mengirim email: ${e.toString()}';
      print('Forgot password error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resendEmail(String email) {
    emailSent.value = false;
    sendResetEmail(email);
  }

  void goBackToLogin() => Get.offAllNamed('/login');
}