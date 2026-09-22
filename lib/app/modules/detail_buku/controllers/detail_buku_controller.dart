import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/review_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';

/// Controller halaman Detail Buku: menampilkan sinopsis, ulasan, dan
/// aksi bookmark / mulai baca.
class DetailBukuController extends GetxController {
  late final BookModel book;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    book = Get.arguments is BookModel ? Get.arguments as BookModel : MockData.detailBook;
    reviews.assignAll(MockData.reviews);
  }

  void toggleSynopsis() => isSynopsisExpanded.toggle();

  void toggleBookmark() => isBookmarked.toggle();

  void startReading() => Get.toNamed(Routes.READER, arguments: book);

  /// Status login pengguna saat ini, dipakai untuk menentukan alur ulasan:
  /// - true  → form ulasan bisa langsung dibuka & dikirim tanpa hambatan.
  /// - false → jangan buka form, arahkan langsung ke halaman masuk.
  ///
  /// PENTING: hanya bergantung pada sesi Supabase (`isLoggedIn`), BUKAN pada
  /// `currentUser` (profil dari tabel `users`). Profil bisa saja gagal/belum
  /// termuat (lihat SupabaseAuthService._loadUserData) walau sesi login
  /// valid — kalau ikut disyaratkan di sini, pengguna yang sudah login akan
  /// terus dianggap belum login dan terus diarahkan ke halaman masuk.
  bool get isLoggedIn => AuthService.to.isLoggedIn.value;

  /// Dipanggil saat pengguna yang BELUM login menekan "Tulis Ulasan".
  /// Form ulasan tidak dibuka; pengguna langsung diarahkan ke halaman masuk
  /// supaya tidak perlu mengisi ulasan dulu baru gagal terkirim.
  void promptLoginToReview() {
    Get.snackbar(
      'review_login_required_title'.tr,
      'review_login_required_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed(Routes.LOGIN);
  }

  /// Menambahkan ulasan baru dari pengguna yang sedang login.
  /// Form ulasan hanya dibuka untuk pengguna yang sudah login (lihat
  /// [isLoggedIn] & [promptLoginToReview]), jadi di sini pengiriman
  /// dilakukan langsung; pengecekan login tetap dipertahankan sebagai
  /// pengaman kedua (mis. sesi berakhir saat form masih terbuka).
  /// Mengembalikan true jika berhasil ditambahkan.
  bool submitReview({required int rating, required String comment}) {
    if (!isLoggedIn) {
      promptLoginToReview();
      return false;
    }
    // Profil (currentUser) bisa saja belum/gagal termuat walau sesi login
    // valid — jangan blokir pengiriman ulasan karena ini, cukup pakai nama
    // cadangan supaya ulasan tetap bisa terkirim.
    final user = AuthService.to.currentUser.value;
    final displayName = user?.name ?? 'review_default_username'.tr;
    if (comment.trim().isEmpty) {
      Get.snackbar(
        'review_empty_title'.tr,
        'review_empty_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    reviews.insert(
      0,
      ReviewModel(
        name: displayName,
        avatarColor: AppColors.accentBlue,
        rating: rating,
        timeAgo: 'review_just_now'.tr,
        comment: comment.trim(),
        likes: 0,
      ),
    );
    return true;
  }
}