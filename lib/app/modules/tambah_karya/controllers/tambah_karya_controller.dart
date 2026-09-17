import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller halaman "Tambah Karya Sastra Baru" — form untuk penulis
/// membuat/menerbitkan karya baru (novel, puisi, atau cerpen).
class TambahKaryaController extends GetxController {
  final judulController = TextEditingController();
  final sinopsisController = TextEditingController();
  final isiCeritaController = TextEditingController();
  final tagInputController = TextEditingController();

  final categories = const ['Cerpen', 'Puisi', 'Novel'];
  final RxInt selectedCategoryIndex = 1.obs; // "Puisi" terpilih sesuai contoh desain

  final RxList<String> tags = <String>['#Romansa', '#SMA'].obs;

  final RxBool isSavingDraft = false.obs;
  final RxBool isPublishing = false.obs;
  final RxString coverImageLabel = ''.obs;

  void selectCategory(int index) => selectedCategoryIndex.value = index;

  void addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    final formatted = tag.startsWith('#') ? tag : '#$tag';
    if (!tags.contains(formatted)) tags.add(formatted);
    tagInputController.clear();
  }

  void removeTag(String tag) => tags.remove(tag);

  void pickCoverImage() {
    coverImageLabel.value = 'sampul_karya.jpg';
    Get.snackbar('Unggah Sampul', 'Pilih gambar sampul dari galeri perangkat Anda.',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveDraft() async {
    isSavingDraft.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isSavingDraft.value = false;
    Get.snackbar('Draft Disimpan', 'Karya Anda telah disimpan sebagai draft.',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> publish() async {
    if (judulController.text.trim().isEmpty) {
      Get.snackbar('Judul Kosong', 'Judul karya wajib diisi sebelum publikasi.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isPublishing.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isPublishing.value = false;
    Get.back();
    Get.snackbar('Karya Diterbitkan', 'Karya Anda berhasil dipublikasikan ke KARYAKU.',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    judulController.dispose();
    sinopsisController.dispose();
    isiCeritaController.dispose();
    tagInputController.dispose();
    super.onClose();
  }
}
