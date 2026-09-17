import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/auth_service.dart';

/// Controller halaman "Daftar Sebagai Penulis" — registrasi terpisah dari
/// akun (login/register), diisi setelah pengguna login sebagai pembaca.
class DaftarPenulisController extends GetxController {
  final penNameController = TextEditingController();
  final bioController = TextEditingController();

  final genreOptions = const ['Novel', 'Cerpen', 'Puisi', 'Esai', 'Fiksi Sejarah'];
  final RxList<String> selectedGenres = <String>[].obs;

  final RxBool agreeToGuidelines = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorText = ''.obs;

  void toggleGenre(String genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
  }

  void toggleAgreeToGuidelines(bool? v) => agreeToGuidelines.value = v ?? false;

  Future<void> submit() async {
    final penName = penNameController.text.trim();

    if (penName.isEmpty) {
      errorText.value = 'Nama pena wajib diisi.';
      return;
    }
    if (selectedGenres.isEmpty) {
      errorText.value = 'Pilih minimal satu genre yang diminati.';
      return;
    }
    if (!agreeToGuidelines.value) {
      errorText.value = 'Anda harus menyetujui Pedoman Penulis KARYAKU.';
      return;
    }

    errorText.value = '';
    isSubmitting.value = true;

    // Simulasi proses registrasi penulis ke backend.
    await Future.delayed(const Duration(milliseconds: 800));

    AuthService.to.becomeWriter(
      penName: penName,
      favoriteGenres: selectedGenres.toList(),
    );

    isSubmitting.value = false;
    Get.back();
    Get.snackbar(
      'Selamat, ${penName}!',
      'Anda resmi terdaftar sebagai penulis di KARYAKU.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    penNameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}