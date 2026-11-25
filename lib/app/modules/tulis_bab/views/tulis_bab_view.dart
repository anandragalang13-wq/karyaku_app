import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../data/models/work_model.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/book_cover.dart';
import '../controllers/tulis_bab_controller.dart';

/// Layar menulis bab baru untuk sebuah karya yang masih draft.
class TulisBabView extends GetView<TulisBabController> {
  const TulisBabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: Text('chapter_editor_title'.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isSaving.value ? null : controller.save,
              icon: controller.isSaving.value
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save_rounded, size: 18),
              label: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : Text('chapter_editor_save'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final work = controller.work;
    if (work == null) {
      return Center(
        child: Text('manage_works_empty_desc'.tr,
            style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    final number = controller.chapterNumber;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _WorkHeader(work: work, chapterNumber: number),
        if (!controller.canWrite) ...[
          const SizedBox(height: 14),
          Container(
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
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        const _FieldLabel('chapter_editor_title_label'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.judulController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: 'chapter_editor_title_hint'.tr),
        ),
        const SizedBox(height: 20),
        const _FieldLabel('chapter_editor_content_label'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              QuillSimpleToolbar(
                controller: controller.quillController,
                config: const QuillSimpleToolbarConfig(
                  showAlignmentButtons: false,
                  showBackgroundColorButton: false,
                  showBoldButton: true,
                  showCenterAlignment: false,
                  showClearFormat: true,
                  showCodeBlock: false,
                  showColorButton: false,
                  showDirection: false,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showInlineCode: false,
                  showItalicButton: true,
                  showJustifyAlignment: false,
                  showLeftAlignment: false,
                  showLink: true,
                  showListBullets: true,
                  showListCheck: false,
                  showListNumbers: true,
                  showQuote: true,
                  showRedo: true,
                  showRightAlignment: false,
                  showSearchButton: false,
                  showSmallButton: false,
                  showStrikeThrough: true,
                  showSubscript: false,
                  showSuperscript: false,
                  showUndo: true,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  toolbarSectionSpacing: 8,
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              Container(
                height: 300,
                padding: const EdgeInsets.all(12),
                child: QuillEditor.basic(
                  controller: controller.quillController,
                  config: QuillEditorConfig(
                    padding: EdgeInsets.zero,
                    expands: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ringkasan karya + nomor bab yang sedang ditulis.
class _WorkHeader extends StatelessWidget {
  final WorkModel work;
  final int chapterNumber;
  const _WorkHeader({required this.work, required this.chapterNumber});

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
            width: 44,
            height: 60,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'chapter_editor_number'.trArgs(['$chapterNumber']),
                    style: const TextStyle(
                        color: AppColors.accentBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String keyName;
  const _FieldLabel(this.keyName);

  @override
  Widget build(BuildContext context) {
    return Text(
      keyName.tr,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
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
