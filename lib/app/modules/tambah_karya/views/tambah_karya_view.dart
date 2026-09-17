import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/tambah_karya_controller.dart';

class TambahKaryaView extends GetView<TambahKaryaController> {
  const TambahKaryaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Tambah Karya Sastra Baru',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Disimpan Draft',
                  style: TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Center(
            child: GestureDetector(
              onTap: controller.pickCoverImage,
              child: Obx(
                () => Container(
                  width: 140,
                  height: 187, // rasio 3:4
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: controller.coverImageLabel.value.isEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background,
                              ),
                              child: Icon(Icons.camera_alt_outlined,
                                  color: AppColors.textMuted, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text('Unggah Sampul Buku',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                            Text('(Rasio 3:4)',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_rounded, color: AppColors.accentBlue, size: 32),
                            const SizedBox(height: 8),
                            Text(controller.coverImageLabel.value,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _FieldLabel('Judul Karya'),
          const SizedBox(height: 8),
          TextField(
            controller: controller.judulController,
            decoration: const InputDecoration(hintText: 'Masukkan judul...'),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Kategori'),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: List.generate(controller.categories.length, (i) {
                final selected = controller.selectedCategoryIndex.value == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => controller.selectCategory(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryNavy : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppColors.primaryNavy : AppColors.border,
                        ),
                      ),
                      child: Text(
                        controller.categories[i],
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Tags'),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...controller.tags.map(
                  (tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close_rounded, size: 15),
                    onDeleted: () => controller.removeTag(tag),
                    backgroundColor: AppColors.background,
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: controller.tagInputController,
                    onSubmitted: controller.addTag,
                    decoration: const InputDecoration(
                      hintText: 'Tambah tag...',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Sinopsis / Deskripsi Karya'),
          const SizedBox(height: 8),
          TextField(
            controller: controller.sinopsisController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Tuliskan sinopsis singkat...'),
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Isi Cerita / Bab 1'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _ToolbarIcon(Icons.format_bold_rounded),
                      _ToolbarIcon(Icons.format_italic_rounded),
                      _ToolbarIcon(Icons.format_underline_rounded),
                      _ToolbarIcon(Icons.format_list_bulleted_rounded),
                      _ToolbarIcon(Icons.format_quote_rounded),
                    ],
                  ),
                ),
                TextField(
                  controller: controller.isiCeritaController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Mulai menulis ceritamu di sini...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => OutlinedButton(
                    onPressed: controller.isSavingDraft.value ? null : controller.saveDraft,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.primaryNavy),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isSavingDraft.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('Simpan Draft'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isPublishing.value ? null : controller.publish,
                    icon: controller.isPublishing.value
                        ? const SizedBox.shrink()
                        : const Icon(Icons.rocket_launch_rounded, size: 18),
                    label: controller.isPublishing.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: Colors.white),
                          )
                        : const Text('Publikasikan Karya'),
                  ),
                ),
              ),
            ],
          ),
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
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  const _ToolbarIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );
  }
}
