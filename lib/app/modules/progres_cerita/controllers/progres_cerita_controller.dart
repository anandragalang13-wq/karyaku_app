import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/chapter_content.dart';
import '../../../data/models/work_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/book_service.dart';
import '../../../theme/app_colors.dart';

/// Controller halaman "Edit Karya" / "Progres Cerita".
///
/// Halaman ini ditampilkan **pertama kali** saat penulis menekan tombol
/// "Edit Karya" dari "Kelola Karya", bukan langsung editor bab kosong.
/// Di sini penulis bisa melihat & mengedit teks/puisi bab sebelumnya,
/// meninjau progres ceritanya, lalu menekan tombol "Tambah Bab Baru"
/// untuk melanjutkan menulis bab baru — semuanya dalam satu halaman.
class ProgresCeritaController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<WorkModel?> work = Rx<WorkModel?>(null);

  /// Nomor bab yang sedang terbuka (dibuka-tutup) di daftar progres.
  final RxSet<int> expandedChapters = <int>{}.obs;

  // ------------------------------------------------------------------
  // MODE EDIT BAB (lihat/ubah teks atau puisi bab sebelumnya)
  // ------------------------------------------------------------------

  /// Field judul & isi saat mengedit bab (0 = tidak sedang mengedit).
  final RxInt editingNumber = 0.obs;
  final RxBool isSaving = false.obs;
  final TextEditingController editTitleController = TextEditingController();
  final TextEditingController editBodyController = TextEditingController();

  /// Apakah ada bab yang sedang diedit sekarang?
  bool get isEditing => editingNumber.value != 0;

  bool isEditingChapter(int number) =>
      editingNumber.value != 0 && editingNumber.value == number;

  WorkModel? get currentWork => work.value;

  /// Bab-bab yang sudah tersimpan pada karya ini.
  /// Diurutkan secara berurutan: Bab 1 di posisi teratas.
  List<ChapterBlock> get chapters {
    final w = work.value;
    if (w == null) return const [];
    final parsed = ChapterContent.parse(w.content);
    // Pastikan urutan: Bab 1, 2, 3... (parse sudah mengembalikan berurutan)
    parsed.sort((a, b) => a.number.compareTo(b.number));
    return parsed;
  }

  /// Bab terakhir yang sudah ditulis (null bila belum ada satupun).
  ChapterBlock? get lastChapter =>
      chapters.isEmpty ? null : chapters.last;

  /// Total kata dari seluruh bab yang sudah tersimpan.
  int get totalWords =>
      chapters.fold<int>(0, (sum, c) => sum + ChapterContent.wordCount(c.body));

  /// Nomor bab berikutnya yang akan ditulis penulis.
  int get nextChapterNumber => work.value == null
      ? 1
      : ChapterContent.nextNumber(
          content: work.value!.content,
          chapterCount: work.value!.chapterCount,
        );

  /// Karya masih boleh ditulis lanjut selama statusnya draft/ditolak (RLS).
  bool get canWrite => work.value?.canEdit() ?? false;

  /// Apakah karya bisa di-submit untuk approval (publish)?
  bool get canPublish => work.value?.canSubmit() ?? false;

  /// Apakah karya sudah approved (terpublish)?
  bool get isPublished => work.value?.canPublish() ?? false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is WorkModel) {
      work.value = args;
      reload();
    }
  }

  /// Memuat ulang karya dari backend (dipanggil saat halaman dibuka dan
  /// setelah bab baru tersimpan supaya progres selalu mutakhir).
  Future<void> reload() async {
    if (work.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final myWorks = await Get.find<BookService>().getMyWorks();
      final updated =
          myWorks.where((w) => w.id == work.value!.id).toList();
      if (updated.isNotEmpty) work.value = updated.first;
    } catch (e) {
      errorMessage.value = 'Gagal memuat progres cerita: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------------
  // DAFTAR BAB (BUKA/TUTUP ISI)
  // ------------------------------------------------------------------

  bool isExpanded(int number) => expandedChapters.contains(number);

  void toggleChapter(int number) {
    if (!expandedChapters.remove(number)) {
      expandedChapters.add(number);
    }
  }

  // ------------------------------------------------------------------
  // MODE EDIT BAB (lihat/ubah teks atau puisi bab sebelumnya)
  // ------------------------------------------------------------------

  /// Mulai mengedit sebuah bab: isi judul & badan teks disalin dari bab
  /// tersebut supaya penulis bisa langsung melanjutkan/mengubah tulisannya.
  void startEdit(ChapterBlock chapter) {
    editTitleController.text = chapter.title;
    editBodyController.text = chapter.body;
    editingNumber.value = chapter.number;
  }

  /// Batalkan mode edit tanpa menyimpan perubahan.
  void cancelEdit() {
    editingNumber.value = 0;
    editTitleController.clear();
    editBodyController.clear();
  }

  /// Simpan perubahan bab yang sedang diedit ke backend.
  Future<void> saveEdit() async {
    final w = work.value;
    final number = editingNumber.value;
    if (w == null || !canWrite || number <= 0) return;

    final body = editBodyController.text.trim();
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
      final newContent = ChapterContent.replace(
        content: w.content,
        number: number,
        title: editTitleController.text.trim(),
        body: body,
      );

      await Get.find<BookService>()
          .saveWorkContent(bookId: w.id, content: newContent);

      cancelEdit();
      await reload();
      Get.snackbar(
        'story_progress_updated_title'.tr,
        'story_progress_updated_message'.trArgs(['$number']),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'story_progress_update_failed'.tr,
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

  // ------------------------------------------------------------------
  // AKSI
  // ------------------------------------------------------------------

  /// Membuka editor bab baru **setelah** penulis meninjau progres.
  /// Data progres disegarkan kembali setelah bab tersimpan.
  Future<void> openAddChapter() async {
    final w = work.value;
    if (w == null || !canWrite || isEditing) return;

    final saved = await Get.toNamed(Routes.TULIS_BAB, arguments: w);
    if (saved == true) await reload();
  }

  /// Menghapus sebuah bab dari karya.
  Future<void> deleteChapter(int number) async {
    final w = work.value;
    if (w == null || !canWrite) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('story_progress_delete_title'.tr),
        content: Text('story_progress_delete_message'.trArgs(['$number'])),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('story_progress_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('story_progress_delete'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isSaving.value = true;
    try {
      final newContent = ChapterContent.remove(content: w.content, number: number);
      await Get.find<BookService>().saveWorkContent(bookId: w.id, content: newContent);
      await reload();
      Get.snackbar(
        'story_progress_delete_title'.tr,
        'story_progress_delete_success'.trArgs(['$number']),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'story_progress_update_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Mengirimkan karya untuk approval (publish).
  Future<void> publishWork() async {
    final w = work.value;
    if (w == null || !canPublish) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('story_progress_publish_title'.tr),
        content: Text('story_progress_publish_message'.trArgs([w.title])),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('story_progress_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('add_work_publish'.tr, style: TextStyle(color: AppColors.accentBlue)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isSaving.value = true;
    try {
      await Get.find<BookService>().submitForApproval(w.id);
      await reload();
      Get.snackbar(
        'story_progress_publish_title'.tr,
        'story_progress_publish_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'story_progress_update_failed'.tr,
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    editTitleController.dispose();
    editBodyController.dispose();
    super.onClose();
  }
}
