import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';
import '../../../theme/app_colors.dart';
import '../../umpan_balik/controllers/umpan_balik_controller.dart';
import '../../umpan_balik/views/umpan_balik_view.dart';

/// Controller halaman Profil pengguna.
class ProfilController extends GetxController {
  /// Diambil lewat getter supaya halaman tetap bisa dibuka (dan diuji)
  /// walau service autentikasi belum terdaftar.
  AuthService get _auth => AuthService.to;

  bool get isLoggedIn => _auth.isLoggedIn.value;

  /// User kosong dipakai sebagai placeholder saat belum login,
  /// supaya view tidak perlu menangani null.
  UserModel get user =>
      _auth.currentUser.value ??
      const UserModel(
        id: '',
        name: '',
        email: '',
        badge: '',
        karyaDibaca: 0,
        koleksi: 0,
        pengikut: 0,
      );

  /// Pengaturan & Bantuan bisa diakses tanpa login.
  void openSettings() => Get.toNamed(Routes.PENGATURAN_AKUN);
  void openKelolaKarya() => Get.toNamed(Routes.KELOLA_KARYA);

  void openHelp() {
    Get.defaultDialog(
      title: 'profile_help_feedback'.tr,
      middleText: 'profile_help_dialog_message'.tr,
      textConfirm: 'common_close'.tr,
      onConfirm: () => Get.back(),
    );
  }

  /// Membuka form umpan balik (bottom sheet).
  ///
  /// Form ini benar-benar bekerja: pesan dikirim ke tabel `feedback` di
  /// Supabase lewat `FeedbackService` — bukan sekadar dialog informasi.
  /// Umpan balik butuh akun, jadi user yang belum login diarahkan ke
  /// halaman masuk lebih dulu.
  void openFeedback() {
    if (!isLoggedIn) {
      Get.snackbar(
        'feedback_login_required_title'.tr,
        'feedback_login_required_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(Routes.LOGIN);
      return;
    }

    final form = Get.put(UmpanBalikController());
    form.reset();

    Get.bottomSheet(
      const UmpanBalikSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ).whenComplete(() {
      Get.delete<UmpanBalikController>();
    });
  }

  bool get isWriter => user.isWriter;

  /// Jumlah karya milik user sendiri (draft/diterbit). Dipakai supaya menu
  /// "Kelola Karya" tetap terlihat bagi penulis yang(databases-nya) karyanya
  /// sudah ada, walau status `is_writer` belum pernah diaktifkan.
  final RxInt ownWorksCount = 0.obs;

  /// Apakah menu "Kelola Karya" perlu ditampilkan?
  bool get showManageWorks => isWriter || ownWorksCount.value > 0;

  /// `true` bila profil user belum tersimpan di tabel `users` (tabelnya
  /// belum dibuat di Supabase). Aplikasi tetap bisa dipakai, tapi fitur
  /// yang butuh tabel `users` (pendaftaran penulis, statistik) belum aktif.
  bool get profileMissing =>
      isLoggedIn &&
      Get.isRegistered<AuthService>() &&
      !AuthService.to.profileSynced.value;

  @override
  void onInit() {
    super.onInit();
    loadOwnWorksCount();
  }

  /// Menghitung karya milik user sendiri (best-effort).
  Future<void> loadOwnWorksCount() async {
    if (!isLoggedIn) {
      ownWorksCount.value = 0;
      return;
    }
    if (!Get.isRegistered<BookService>()) return;

    try {
      final works = await Get.find<BookService>().getMyWorks();
      ownWorksCount.value = works.length;
    } catch (e) {
      print('Load own works error: $e');
    }
  }

  /// Pembaca yang belum jadi penulis: buka form registrasi penulis
  /// terpisah (nama pena, genre, dsb). Wajib login dulu karena data
  /// penulis melekat pada akun pengguna — kalau masih guest, arahkan
  /// ke halaman login dulu.
  void goToWriterRegistration() {
    if (!isLoggedIn) {
      Get.toNamed(Routes.LOGIN);
      Get.snackbar(
        'review_login_required_title'.tr,
        'profile_writer_login_required_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(Routes.DAFTAR_PENULIS);
  }

  /// Hanya bisa diakses setelah resmi jadi penulis: buka form Tambah Karya.
  void addNewWork() => Get.toNamed(Routes.TAMBAH_KARYA);

  void logout() {
    Get.defaultDialog(
      title: 'settings_logout_confirm_title'.tr,
      middleText: 'settings_logout_confirm_message'.tr,
      textConfirm: 'settings_logout_confirm_yes'.tr,
      textCancel: 'settings_logout_confirm_cancel'.tr,
      onConfirm: () {
        _auth.logout();
        Get.back();
      },
    );
  }

  void goToLogin() => Get.toNamed(Routes.LOGIN);

  void goToRegister() => Get.toNamed(Routes.REGISTER);
}