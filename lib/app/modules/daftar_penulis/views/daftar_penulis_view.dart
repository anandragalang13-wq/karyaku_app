import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/daftar_penulis_controller.dart';

class DaftarPenulisView extends GetView<DaftarPenulisController> {
  const DaftarPenulisView({super.key});

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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryNavy, Color(0xFF0B1526)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.edit_note_rounded,
                              color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Daftar Sebagai Penulis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lengkapi profil penulis Anda untuk mulai berkarya',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Nama Pena'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.penNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nama yang akan tampil di karya Anda',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.badge_outlined, color: Colors.white.withOpacity(0.7)),
                            filled: true,
                            fillColor: AppColors.primaryNavy,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Bio Singkat (opsional)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controller.bioController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ceritakan sedikit tentang Anda sebagai penulis...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                            filled: true,
                            fillColor: AppColors.primaryNavy,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.primaryNavyLight.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Genre yang Diminati'),
                        const SizedBox(height: 8),
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.genreOptions.map((genre) {
                              final selected = controller.selectedGenres.contains(genre);
                              return ChoiceChip(
                                label: Text(genre),
                                selected: selected,
                                onSelected: (_) => controller.toggleGenre(genre),
                                selectedColor: AppColors.accentBlue.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: selected ? AppColors.accentBlue : AppColors.border,
                                ),
                                backgroundColor: AppColors.surface,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: controller.agreeToGuidelines.value,
                                  onChanged: controller.toggleAgreeToGuidelines,
                                  activeColor: AppColors.primaryNavy,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    'Saya menyetujui Pedoman Penulis dan Kebijakan Konten KARYAKU.',
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
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  controller.isSubmitting.value ? null : controller.submit,
                              child: controller.isSubmitting.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Daftar Sekarang'),
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