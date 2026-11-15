import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../../../services/feedback_service.dart';

/// Controller form umpan balik (halaman Profil > Bantuan & Umpan Balik).
///
/// Data dikirim ke tabel `feedback` di Supabase lewat [FeedbackService],
/// jadi tidak ada data dummy yang hanya disimpan di perangkat.
class UmpanBalikController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  /// Kategori umpan balik. Nilai yang disimpan ke database ada di
  /// [categoryValues], sedangkan yang ditampilkan ke user memakai
  /// terjemahan dari [categoryKeys].
  static const List<String> categoryKeys = [
    'feedback_category_bug',
    'feedback_category_feature',
    'feedback_category_content',
    'feedback_category_other',
  ];

  static const List<String> categoryValues = [
    'Bug',
    'Fitur',
    'Konten',
    'Lainnya',
  ];

  final RxInt selectedCategoryIndex = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorText = ''.obs;

  String get selectedCategory => categoryValues[selectedCategoryIndex.value];

  String labelFor(int index) => categoryKeys[index].tr;

  /// Mengosongkan form (dipakai setiap kali sheet dibuka ulang).
  void reset() {
    messageController.clear();
    selectedCategoryIndex.value = 0;
    errorText.value = '';
    isSubmitting.value = false;
  }

  /// Mengirim umpan balik ke database.
  ///
  /// Mengembalikan `true` bila berhasil disimpan.
  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    final message = messageController.text.trim();
    if (message.isEmpty) {
      errorText.value = 'feedback_empty'.tr;
      return false;
    }

    isSubmitting.value = true;
    errorText.value = '';

    try {
      final user = AuthService.to.currentUser.value;
      final ok = await FeedbackService.to.submit(
        category: selectedCategory,
        message: message,
        email: user?.email,
      );

      if (!ok) {
        errorText.value = 'feedback_failed'.tr;
        return false;
      }

      messageController.clear();
      return true;
    } catch (e) {
      print('Submit feedback error: $e');
      errorText.value = 'feedback_failed'.tr;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
