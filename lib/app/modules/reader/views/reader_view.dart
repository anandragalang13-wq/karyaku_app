import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/locale_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart' as app_theme;
import '../controllers/reader_controller.dart';

class ReaderView extends GetView<ReaderController> {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: controller.theme.value.background,
        appBar: AppBar(
          backgroundColor: controller.theme.value.background,
          elevation: 0,
          foregroundColor: controller.theme.value.textColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.text_fields_rounded),
              onPressed: () => _openReaderSettings(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul bab: "Bab {nomor} {judul}" — ditampilkan di badan
              // halaman (bukan di app bar), tebal & miring seperti reader
              // pada umumnya.
              Text(
                'Bab ${ReaderController.sampleChapterNumber} ${ReaderController.sampleChapterTitle}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                  color: controller.theme.value.textColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ReaderController.sampleChapterText,
                style: controller.font.value.textStyle(
                  fontSize: controller.fontSize.value,
                  color: controller.theme.value.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReaderSettings(BuildContext context) {
    Get.bottomSheet(
      const _ReaderSettingsSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class _ReaderSettingsSheet extends GetView<ReaderController> {
  const _ReaderSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // SEKSI BAHASA
          Text(
            'reader_language_label'.tr,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppLanguage.values
                .map((lang) => _LanguageChip(language: lang))
                .toList(),
          ),

          const SizedBox(height: 24),

          // SEKSI TEMA
          Text(
            'reader_theme'.tr,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 16,
              runSpacing: 12,
              children: app_theme.ReaderTheme.values.map((app_theme.ReaderTheme t) {
                final selected = controller.theme.value == t;
                return GestureDetector(
                  onTap: () => controller.setTheme(t),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: t.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.accentOrange
                                : AppColors.border,
                            width: selected ? 2.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Aa',
                          style: TextStyle(
                            color: t.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // SEKSI JENIS HURUF
          Text(
            'reader_font_type'.tr,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: app_theme.ReaderFont.values.map((app_theme.ReaderFont f) {
                final selected = controller.font.value == f;
                return GestureDetector(
                  onTap: () => controller.setFont(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryNavy
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryNavy
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      f.label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // SEKSI UKURAN HURUF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'reader_font_size_label'.tr,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Obx(
                () => Text(
                  '${controller.fontSize.value.round()} pt',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: controller.fontSize.value,
                    min: 13,
                    max: 26,
                    divisions: 13,
                    activeColor: AppColors.primaryNavy,
                    onChanged: controller.setFontSize,
                  ),
                ),
                const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pendukung pilihan bahasa. Memakai LocaleService yang sama dengan
// halaman Pengaturan supaya pilihan bahasa konsisten & tersimpan.
class _LanguageChip extends StatelessWidget {
  final AppLanguage language;

  const _LanguageChip({
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();

    return Obx(() {
      final selected = localeService.currentLanguage.value == language;

      return GestureDetector(
        onTap: () => localeService.changeLanguage(language),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentBlue : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.accentBlue : AppColors.border,
            ),
          ),
          child: Text(
            language.displayName,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}