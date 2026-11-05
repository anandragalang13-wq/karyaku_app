import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chapter_content.dart';
import '../../../data/models/work_model.dart';
import '../../../services/book_service.dart';

/// Controller layar "Tulis Bab Baru".
///
/// Menerima [WorkModel] lewat arguments, lalu menyimpan blok bab baru ke
/// kolom `books.content` beserta jumlah bab-nya.
class TulisBabController extends GetxController {
  final judulController = TextEditingController();
  final isiController = TextEditingController();
  final RxBool isSaving = false.obs;

  WorkModel? _work;
  WorkModel? get work => _work;

  /// Nomor bab berikutnya berdasarkan bab yang sudah tertulis.
  int get chapterNumber => _work == null
      ? 1
      : ChapterContent.nextNumber(
          content: _work!.content,
          chapterCount: _work!.chapterCount,
        );

  /// Karya masih boleh ditulis lanjut selama statusnya draft/ditolak (RLS).
  bool get canWrite => _work?.canEdit() ?? false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is WorkModel) _work = args;
  }

  @override
  void onClose() {
    judulController.dispose();
    isiController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final work = _work;
    if (work == null) return;

    final body = isiController.text.trim();
    if (body.isEmpty) {
      Get.snackbar(
        'chapter_editor_title'.tr,
        'chapter_editor_content_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;
    try {
      final number = chapterNumber;
      final newContent = ChapterContent.append(
        content: work.content,
        number: number,
        title: judulController.text.trim(),
        body: body,
      );

      await Get.find<BookService>().saveChapter(
        bookId: work.id,
        content: newContent,
        totalChapters: number,
        currentChapter: number,
      );

      Get.back(result: true);
      Get.snackbar(
        'chapter_editor_saved_title'.tr,
        'chapter_editor_saved_message'.trArgs(['$number']),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'chapter_editor_save_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
