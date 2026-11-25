import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/tambah_puisi_controller.dart';

class TambahPuisiView extends GetView<TambahPuisiController> {
  const TambahPuisiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Tulis Puisi Baru',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.badgePuisi.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Puisi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.badgePuisi,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // Cover Upload
            _buildCoverSection(),
            const SizedBox(height: 20),

            // Judul
            _buildLabel('Judul Puisi'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.judulController,
              decoration: _inputDecoration(
                'Masukkan judul puisi',
                Icons.title_rounded,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Judul tidak boleh kosong'
                  : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Sinopsis (opsional)
            _buildLabel('Sinopsis (Opsional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.sinopsisController,
              maxLines: 3,
              decoration: _inputDecoration(
                'Ringkasan singkat puisi...',
                Icons.description_rounded,
              ),
            ),
            const SizedBox(height: 20),

            // Isi Puisi
            _buildLabel('Isi Puisi'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.isiPuisiController,
              maxLines: 12,
              minLines: 6,
              decoration: _inputDecoration(
                'Tulis puisi Anda di sini...\n\nGunakan Enter untuk baris baru',
                Icons.edit_note_rounded,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Isi puisi tidak boleh kosong'
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Tags
            _buildLabel('Tag (Maks. 5, pisahkan dengan koma atau Enter)'),
            const SizedBox(height: 8),
            _buildTagInput(),
            const SizedBox(height: 20),

            // Preview tags
            Obx(() => controller.tags.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.tags
                        .map(
                          (t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => controller.removeTag(t),
                            backgroundColor: AppColors.badgePuisi.withValues(alpha: 0.12),
                            side: BorderSide(color: AppColors.badgePuisi.withValues(alpha: 0.3)),
                          ),
                        )
                        .toList(),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Obx(() => OutlinedButton.icon(
                        onPressed: controller.isSavingDraft.value
                            ? null
                            : controller.saveDraft,
                        icon: controller.isSavingDraft.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: const Text('Simpan Draft'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.textSecondary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => FilledButton.icon(
                        onPressed: controller.isPublishing.value
                            ? null
                            : controller.publish,
                        icon: controller.isPublishing.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.publish_rounded),
                        label: const Text('Publikasikan'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.badgePuisi,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.badgePuisi, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.danger),
      ),
    );
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Sampul Puisi'),
        const SizedBox(height: 8),
        Obx(() {
          final hasImage = controller.coverImagePath != null;
          return GestureDetector(
            onTap: controller.pickCoverImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                image: hasImage
                    ? DecorationImage(
                        image: FileImage(File(controller.coverImagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasImage
                  ? Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () {
                                controller.clearCover();
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk pilih gambar sampul',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rekomendasi: 3:4 (misal 600x800 px)',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
        if (controller.coverImageLabel.value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'File: ${controller.coverImageLabel.value}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagInput() {
    return TextField(
      controller: controller.tagInputController,
      decoration: _inputDecoration(
        'Ketik tag lalu tekan Enter atau koma',
        Icons.local_offer_rounded,
      ),
      onSubmitted: (value) => controller.addTag(value),
      onChanged: (value) {
        if (value.endsWith(',')) {
          controller.addTag(value);
        }
      },
      textInputAction: TextInputAction.done,
    );
  }
}