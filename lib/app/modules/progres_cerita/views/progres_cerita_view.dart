import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chapter_content.dart';
import '../../../data/models/work_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../controllers/progres_cerita_controller.dart';

/// Halaman "Progres Cerita": tinjauan progres/ringkasan isi bab sebelumnya
/// yang ditampilkan lebih dulu sebelum penulis menambah bab baru.
class ProgresCeritaView extends GetView<ProgresCeritaController> {
  const ProgresCeritaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: Text('story_progress_title'.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Obx(() {
        final work = controller.currentWork;

        if (work == null) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'manage_works_empty_desc'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _WorkHeader(work: work),
              const SizedBox(height: 14),
              _SummaryCard(controller: controller),
              if (!controller.canWrite) ...[
                const SizedBox(height: 14),
                const _LockedBanner(),
              ],
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'story_progress_previous_content'.tr,
                subtitle: 'story_progress_previous_subtitle'.tr,
              ),
              const SizedBox(height: 12),
              _buildChapterList(),
            ],
          ),
        );
      }),
      // Sementara mengedit bab, aksi utama pindah ke dalam kartu edit
      // (Simpan/Batal) sehingga tombol "Tambah Bab Baru" tidak muncul.
      bottomNavigationBar: Obx(() {
        if (controller.isEditing) return const SizedBox.shrink();

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ElevatedButton.icon(
              onPressed: controller.canWrite && !controller.isLoading.value
                  ? controller.openAddChapter
                  : null,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('story_progress_add_chapter'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.accentBlue.withValues(alpha: 0.4),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Daftar bab tersimpan — tiap bab bisa dibuka untuk membaca isi
  /// lengkapnya (progres isi bab sebelumnya).
  Widget _buildChapterList() {
    final chapters = controller.chapters;

    if (chapters.isEmpty) {
      return const _EmptyChapterCard();
    }

    return Column(
      children: [
        for (final chapter in chapters)
          _ChapterCard(
            controller: controller,
            chapter: chapter,
          ),
      ],
    );
  }
}

// ======================================================================
// HEADER KARYA
// ======================================================================

class _WorkHeader extends StatelessWidget {
  final WorkModel work;
  const _WorkHeader({required this.work});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          BookCoverImage(
            coverAsset: work.cover,
            gradient: _gradientFor(work),
            width: 48,
            height: 66,
            borderRadius: 8,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(work.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Badge(
                      label: work.type.label,
                      color: AppColors.badgeForCategory(work.type.label),
                    ),
                    _Badge(
                      label: work.approvalStatus.label,
                      color: work.approvalStatus.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// RINGKASAN PROGRES
// ======================================================================

class _SummaryCard extends StatelessWidget {
  final ProgresCeritaController controller;
  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final chapters = controller.chapters;
    final nextNumber = controller.nextChapterNumber;

    final stats = [
      _MiniStat(
        label: 'story_progress_chapters_saved'.tr,
        value: '${chapters.length}',
      ),
      _MiniStat(
        label: 'story_progress_total_words'.tr,
        value: '${controller.totalWords}',
      ),
      _MiniStat(
        label: 'story_progress_next_chapter'.tr,
        value: '$nextNumber',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('story_progress_summary'.tr,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final stat in stats) ...[
                Expanded(child: stat),
                if (stat != stats.last)
                  Container(width: 1, height: 30, color: AppColors.border),
              ],
            ],
          ),
          if (chapters.isNotEmpty) ...[
            const SizedBox(height: 14),
            // Titik bab: terisi untuk bab yang sudah ada, garis putus untuk
            // bab berikutnya yang akan ditulis.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chapter in chapters)
                  _ChapterDot(number: chapter.number, filled: true),
                _ChapterDot(number: nextNumber, filled: false),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ======================================================================
// KARTU BAB (PROGRES ISI BAB SEBELUMNYA)
// ======================================================================

class _ChapterCard extends StatelessWidget {
  final ProgresCeritaController controller;
  final ChapterBlock chapter;
  const _ChapterCard({required this.controller, required this.chapter});

  @override
  Widget build(BuildContext context) {
    // Dibungkus Obx: GetX hanya memantau Rx yang dibaca di dalam scope
    // builder Obx, sehingga pembacaan mode edit di bawah harus ikut berada
    // di scope ini — kalau tidak, kartu tidak ikut rebuild saat tombol
    // Edit ditekan dan form edit tidak pernah muncul.
    return Obx(_buildContent);
  }

  Widget _buildContent() {
    // Mode edit: kartu berubah menjadi form untuk melihat/mengubah
    // teks atau puisi bab sebelumnya.
    if (controller.isEditingChapter(chapter.number)) {
      return _EditChapterCard(controller: controller, chapter: chapter);
    }

    final expanded = controller.isExpanded(chapter.number);
    final body = chapter.body.trim();
    final canExpand = body.length > 140;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue,
                ),
                child: Text(
                  '${chapter.number}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.heading,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Text(
                'story_progress_words'.trArgs(
                    ['${ChapterContent.wordCount(body)}']),
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              body,
              maxLines: expanded ? null : 3,
              overflow: expanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          if (canExpand || controller.canWrite)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canExpand)
                    _CardAction(
                      label: expanded
                          ? 'story_progress_collapse'.tr
                          : 'story_progress_expand'.tr,
                      onTap: () => controller.toggleChapter(chapter.number),
                    )
                  else
                    const SizedBox.shrink(),
                  if (controller.canWrite)
                    _CardAction(
                      icon: Icons.edit_rounded,
                      label: 'story_progress_edit'.tr,
                      onTap: () => controller.startEdit(chapter),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ======================================================================
// FORM EDIT BAB (lihat/ubah isi bab sebelumnya)
// ======================================================================

class _EditChapterCard extends StatelessWidget {
  final ProgresCeritaController controller;
  final ChapterBlock chapter;
  const _EditChapterCard({required this.controller, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue,
                ),
                child: Text(
                  '${chapter.number}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'story_progress_editing'.trParams({
                    '@heading': chapter.heading,
                  }),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: controller.cancelEdit,
                tooltip: 'story_progress_cancel'.tr,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.editTitleController,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                InputDecoration(hintText: 'chapter_editor_title_hint'.tr),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller.editBodyController,
              maxLines: 10,
              minLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'chapter_editor_content_hint'.tr,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: controller.cancelEdit,
                child: Text(
                  'story_progress_cancel'.tr,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSaving.value ? null : controller.saveEdit,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 17),
                  label: Text('story_progress_save_changes'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Aksi teks kecil di dalam kartu bab (buka isi / edit).
class _CardAction extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  const _CardAction({this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.accentBlue),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _ChapterDot extends StatelessWidget {
  final int number;
  final bool filled;
  const _ChapterDot({required this.number, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.accentBlue : Colors.transparent,
        border: filled ? null : Border.all(color: AppColors.border, width: 1.5),
      ),
      child: filled
          ? Text('$number',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800))
          : Text('$number',
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 3),
        Text(subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: AppColors.accentOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'manage_works_locked_desc'.tr,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChapterCard extends StatelessWidget {
  const _EmptyChapterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: const Icon(Icons.history_edu_rounded,
                size: 26, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text('story_progress_empty_title'.tr,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'story_progress_empty_desc'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Gradasi placeholder cover berdasarkan kategori karya.
List<Color> _gradientFor(WorkModel work) {
  switch (work.type) {
    case WorkType.puisi:
      return const [Color(0xFF1D5FBF), Color(0xFF0E2E63)];
    case WorkType.cerpen:
      return const [Color(0xFF2E9E5B), Color(0xFF14512F)];
    case WorkType.novel:
      return const [Color(0xFF1F3A5F), Color(0xFF0B1526)];
  }
}
