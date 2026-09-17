import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karyaku_app/app/modules/register/controllers/register_controller.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/auth_header.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const AuthHeader(subtitle: 'Buat Akun Baru di KARYAKU'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Nama Lengkap'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.nameController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nama lengkap Anda',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Email'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan email Anda',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Kata Sandi'),
                        const SizedBox(height: 6),
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.isPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Buat kata sandi (min. 6 karakter)',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Konfirmasi Kata Sandi'),
                        const SizedBox(height: 6),
                        Obx(
                          () => TextField(
                            controller: controller.confirmPasswordController,
                            obscureText: controller.isConfirmPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Ulangi kata sandi Anda',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: controller.toggleConfirmPasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: controller.agreeToTerms.value,
                                  onChanged: controller.toggleAgreeToTerms,
                                  activeColor: AppColors.primaryNavy,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    'Saya menyetujui Syarat & Ketentuan serta '
                                    'Kebijakan Privasi KARYAKU.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary, fontSize: 12.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => controller.errorText.value.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    controller.errorText.value,
                                    style: const TextStyle(
                                        color: AppColors.danger, fontSize: 12.5),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  controller.isLoading.value ? null : controller.register,
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Daftar'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: controller.goToLogin,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13),
                                children: const [
                                  TextSpan(text: 'Sudah punya akun? '),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: TextStyle(
                                      color: AppColors.accentBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
