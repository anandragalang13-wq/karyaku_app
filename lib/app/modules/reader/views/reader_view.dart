import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/locale_service.dart';
import '../../../services/reading_prefs_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart' as app_theme;
import '../controllers/reader_controller.dart';

class ReaderView extends GetView<ReaderController> {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final chapter = controller.currentChapter;
        final colors = controller.theme.value;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            foregroundColor: colors.textColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              // Daftar isi: pilih bab langsung dari daftar 5 bab.
              IconButton(
                icon: const Icon(Icons.menu_book_rounded),
                onPressed: () => _openChapterList(context),
              ),
              IconButton(
                icon: const Icon(Icons.text_fields_rounded),
                onPressed: () => _openReaderSettings(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul bab: "Bab {nomor} {judul}" — ditampilkan di badan
                // halaman (bukan di app bar), tebal & miring seperti reader
                // pada umumnya.
                Text(
                  '${'reader_chapter_label'.tr} ${chapter.number} ${chapter.title}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: colors.textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 28),
                // Konten bab dengan tipografi yang dirapikan
                SelectableText(
                  chapter.content,
                  style: controller.fontTextStyle(
                    fontSize: controller.fontSize.value,
                    color: colors.textColor,
                    height: 1.8, // line spacing yang lebih longgar
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 40),
                _ChapterNavigation(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Daftar isi novel: 5 bab, bab yang sedang dibaca ditandai.
  void _openChapterList(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(
          () {
            final selected = controller.currentChapterIndex.value;
            final chapters = controller.chapters;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'reader_chapter_list'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < chapters.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      i == selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    title: Text(
                      '${'reader_chapter_label'.tr} ${chapters[i].number} '
                      '${chapters[i].title}',
                      style: TextStyle(
                        fontWeight:
                            i == selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      chapters[i].content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      controller.goToChapter(i);
                      Get.back();
                    },
                  ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    min: ReadingPrefsService.minFontSize,
                    max: ReadingPrefsService.maxFontSize,
                    divisions: (ReadingPrefsService.maxFontSize -
                            ReadingPrefsService.minFontSize)
                        .round(),
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

// Navigasi antar bab: Sebelumnya — "Bab X dari 5" — Berikutnya.
// Tombol dinonaktifkan otomatis di bab pertama/terakhir.
class _ChapterNavigation extends StatelessWidget {
  final ReaderController controller;

  const _ChapterNavigation({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasPrev = controller.hasPreviousChapter;
    final hasNext = controller.hasNextChapter;
    final current = controller.currentChapterIndex.value + 1;
    final total = controller.chapters.length;
    final textColor = controller.theme.value.textColor;

    final enabledStyle = TextStyle(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );
    const disabledStyle = TextStyle(
      color: AppColors.textMuted,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );

    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: hasPrev ? controller.previousChapter : null,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 14,
                color: hasPrev ? textColor : AppColors.textMuted,
              ),
              label: Text(
                'reader_prev_chapter'.tr,
                style: hasPrev ? enabledStyle : disabledStyle,
              ),
            ),
            Text(
              'reader_chapter_progress'.trArgs(['$current', '$total']),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: hasNext ? controller.nextChapter : null,
              label: Text(
                'reader_next_chapter'.tr,
                style: hasNext ? enabledStyle : disabledStyle,
              ),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: hasNext ? textColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}