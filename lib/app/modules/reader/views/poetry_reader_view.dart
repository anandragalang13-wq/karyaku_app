import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/work_model.dart';
import '../../../services/locale_service.dart';
import '../../../services/reading_prefs_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart' as app_theme;
import '../controllers/reader_controller.dart';

/// Halaman baca khusus untuk Puisi.
/// Menampilkan puisi utuh dengan tipografi estetis, tanpa navigasi bab.
class PoetryReaderView extends GetView<ReaderController> {
  final WorkModel work;

  const PoetryReaderView({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final colors = controller.theme.value;
        final themeColor = _getThemeColor(work.tags);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            foregroundColor: colors.textColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.text_fields_rounded),
                onPressed: () => _openReaderSettings(context),
              ),
            ],
            flexibleSpace: _buildAppBarGradient(themeColor),
          ),
          body: SingleChildScrollView(
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_quote_rounded, size: 14, color: themeColor),
                      const SizedBox(width: 6),
                      Text(
                        'Puisi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Judul Puisi
                Text(
                  work.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.textColor,
                    height: 1.3,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Penulis
                if (work.authorName != null) ...[
                  Text(
                    'Oleh ${work.authorName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Garis pemisah estetis
                _buildDivider(themeColor),
                const SizedBox(height: 24),

                // Isi Puisi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    work.content,
                    textAlign: TextAlign.left,
                    style: controller.fontTextStyle(
                      fontSize: controller.fontSize.value + 2, // Sedikit lebih besar untuk puisi
                      color: colors.textColor,
                      height: 2.0, // Line spacing sangat longgar untuk puisi
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tag
                if (work.tags.isNotEmpty) ...[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: work.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite_border_rounded,
                      label: 'Sukai',
                      color: themeColor,
                      onTap: () {
                        Get.snackbar(
                          'Fitur',
                          'Fitur suka puisi akan segera hadir',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: themeColor,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'Bagikan',
                      color: themeColor,
                      onTap: () {
                        controller.shareWork(work);
                      },
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Simpan',
                      color: themeColor,
                      onTap: () {
                        controller.toggleBookmark(work);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarGradient(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildDivider(Color themeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                themeColor.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.format_quote_rounded,
          size: 18,
          color: themeColor.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeColor.withValues(alpha: 0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  void _openReaderSettings(BuildContext context) {
    Get.bottomSheet(
      const _PoetryReaderSettingsSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  Color _getThemeColor(List<String> tags) {
    if (tags.isEmpty) return AppColors.badgePuisi;
    final tag = tags.first.toLowerCase();
    if (tag.contains('cinta') || tag.contains('romantis') || tag.contains('love')) {
      return const Color(0xFFE91E63);
    }
    if (tag.contains('malam') || tag.contains('gelap') || tag.contains('night')) {
      return const Color(0xFF673AB7);
    }
    if (tag.contains('alam') || tag.contains('nature') || tag.contains('hijau')) {
      return const Color(0xFF4CAF50);
    }
    if (tag.contains('sedih') || tag.contains('galau') || tag.contains('duka')) {
      return const Color(0xFF2196F3);
    }
    if (tag.contains('harapan') || tag.contains('semangat') || tag.contains('motivasi')) {
      return const Color(0xFFFF9800);
    }
    return AppColors.badgePuisi;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet pengaturan baca untuk Puisi (mirip _ReaderSettingsSheet tapi standalone).
class _PoetryReaderSettingsSheet extends GetView<ReaderController> {
  const _PoetryReaderSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
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