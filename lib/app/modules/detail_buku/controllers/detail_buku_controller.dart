import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/work_model.dart';
import '../../../data/models/work_model_exension.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';
import '../../../theme/app_colors.dart';

/// Controller halaman Detail Buku: menampilkan sinopsis, ulasan, dan
/// aksi bookmark / mulai baca.
class DetailBukuController extends GetxController {
  late final BookModel book;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isBookmarked = false.obs;

  BookService get _books => Get.find<BookService>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is BookModel) {
      book = args;
    } else if (args is WorkModel) {
      book = args.toBookModel();
    } else {
      book = MockData.detailBook; // fallback bila dibuka tanpa argumen
    }
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final list = await _books.getReviews(book.id);
    reviews.assignAll(list);
  }

  void toggleSynopsis() => isSynopsisExpanded.toggle();

  void toggleBookmark() => isBookmarked.toggle();

  void startReading() => Get.toNamed(Routes.READER, arguments: book);

  /// Status login pengguna saat ini. Hanya bergantung pada sesi Supabase
  /// (`isLoggedIn`), BUKAN pada `currentUser` (profil dari tabel `users`),
  /// supaya profil yang gagal termuat tidak membuat user dianggap logout.
  bool get isLoggedIn => AuthService.to.isLoggedIn.value;

  void promptLoginToReview() {
    Get.snackbar(
      'review_login_required_title'.tr,
      'review_login_required_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed(Routes.LOGIN);
  }

  /// Menambahkan ulasan dari pengguna yang sedang login. Ulasan langsung
  /// tampil di daftar (optimistic) lalu disimpan ke Supabase; jika gagal,
  /// ulasan dihapus lagi dari daftar dan user diberi tahu.
  bool submitReview({required int rating, required String comment}) {
    if (!isLoggedIn) {
      promptLoginToReview();
      return false;
    }
    final user = AuthService.to.currentUser.value;
    final displayName = user?.name ?? 'review_default_username'.tr;
    final text = comment.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'review_empty_title'.tr,
        'review_empty_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final review = ReviewModel(
      name: displayName,
      avatarColor: AppColors.accentBlue,
      rating: rating,
      timeAgo: 'review_just_now'.tr,
      comment: text,
      likes: 0,
    );
    reviews.insert(0, review);
    _saveReview(review, rating, text, displayName);
    return true;
  }

  Future<void> _saveReview(
      ReviewModel review, int rating, String comment, String userName) async {
    final ok = await _books.addReview(
      bookId: book.id,
      rating: rating,
      comment: comment,
      userName: userName,
    );
    if (!ok) {
      reviews.remove(review);
      Get.snackbar(
        'Gagal',
        'Ulasan belum tersimpan. Periksa koneksi lalu coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
