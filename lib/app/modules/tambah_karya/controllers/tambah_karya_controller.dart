import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../../data/models/work_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';

class TambahKaryaController extends GetxController {
  // Form Controllers
  final judulController = TextEditingController();
  final sinopsisController = TextEditingController();
  final isiCeritaController = TextEditingController();
  final tagInputController = TextEditingController();

  // Kategori
  final categories = const ['Novel', 'Puisi', 'Cerpen'];
  final selectedCategoryIndex = 0.obs;

  // Tags
  final tags = <String>[].obs;

  // Cover
  final coverImageLabel = ''.obs;
  final _coverImagePath = Rx<String?>(null);
  image_picker.XFile? _coverFile;

  // UI State
  final isSavingDraft = false.obs;
  final isPublishing = false.obs;

  final image_picker.ImagePicker _imagePicker = image_picker.ImagePicker();

  @override
  void onClose() {
    judulController.dispose();
    sinopsisController.dispose();
    isiCeritaController.dispose();
    tagInputController.dispose();
    super.onClose();
  }

  WorkType get selectedType {
    switch (selectedCategoryIndex.value) {
      case 1:
        return WorkType.puisi;
      case 2:
        return WorkType.cerpen;
      default:
        return WorkType.novel;
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  void addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    if (!tags.contains(tag) && tags.length < 5) {
      tags.add(tag);
    }
    tagInputController.clear();
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> pickCoverImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: image_picker.ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _coverImagePath.value = image.path;
        _coverFile = image;
        coverImageLabel.value = image.name;
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
      );
    }
  }

  bool _validateForm() {
    if (judulController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Judul karya tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
      );
      return false;
    }
    if (isiCeritaController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Isi cerita tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
      );
      return false;
    }
    return true;
  }

  void _resetForm() {
    judulController.clear();
    sinopsisController.clear();
    isiCeritaController.clear();
    tagInputController.clear();
    tags.clear();
    selectedCategoryIndex.value = 0;
    coverImageLabel.value = '';
    _coverImagePath.value = null;
    _coverFile = null;
  }

  /// Menyimpan karya ke Supabase. `submit: false` = draft, `true` = pending.
  Future<void> _saveToDatabase({required bool submit}) async {
    if (!AuthService.to.isLoggedIn.value) {
      throw Exception('Silakan masuk terlebih dahulu.');
    }
    final service = Get.find<BookService>();

    String? coverUrl;
    if (_coverFile != null && selectedType.needsCover) {
      coverUrl = await service.uploadCover(_coverFile!);
    }

    await service.saveWork(
      title: judulController.text.trim(),
      category: selectedType.label,
      content: isiCeritaController.text.trim(),
      synopsis: sinopsisController.text,
      tags: tags.toList(),
      coverUrl: coverUrl,
      submit: submit,
    );
  }

  Future<void> saveDraft() async {
    if (!_validateForm()) return;

    isSavingDraft.value = true;
    try {
      await _saveToDatabase(submit: false);
      Get.snackbar(
        'Berhasil',
        'Karya disimpan sebagai draft',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
      );

      _resetForm();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
      );
    } finally {
      isSavingDraft.value = false;
    }
  }

  Future<void> publish() async {
    if (!_validateForm()) return;

    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Publikasikan Karya?'),
            content: Text(
              'Karya "${judulController.text}" akan dikirim ke admin untuk '
              'diverifikasi sebelum tampil ke publik.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Kirim', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    isPublishing.value = true;
    try {
      await _saveToDatabase(submit: true);
      Get.snackbar(
        'Berhasil Dikirim',
        'Karya Anda sedang menunggu persetujuan admin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 3),
      );

      _resetForm();
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mengirim: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
      );
    } finally {
      isPublishing.value = false;
    }
  }
}