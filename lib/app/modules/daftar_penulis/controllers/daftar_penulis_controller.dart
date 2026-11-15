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

    // Pendaftaran benar-benar disimpan ke tabel `users` (status is_writer).
    // Hasilnya dicek: bila gagal, user diberi tahu dan tetap di halaman ini
    // supaya bisa mencoba lagi — bukan sekadar berpindah halaman lalu
    // gagal menemukan fitur tulis karya.
    final ok = await AuthService.to.becomeWriter(
      penName: penName,
      favoriteGenres: selectedGenres.toList(),
    );

    isSubmitting.value = false;

    if (!ok) {
      // Tampilkan alasan sebenarnya dari server (mis. izin RLS), bukan
      // pesan generik, supaya masalahnya mudah ditindaklanjuti.
      final reason = AuthService.to.errorMessage.value.trim();
      errorText.value = reason.isEmpty
          ? 'Gagal menyimpan pendaftaran penulis. Silakan coba lagi.'
          : reason;
      return;
    }

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