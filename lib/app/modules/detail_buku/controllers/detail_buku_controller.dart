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

  /// Menambahkan ulasan baru dari pengguna yang sedang login.
  /// Mengembalikan true jika berhasil ditambahkan.
  bool submitReview({required int rating, required String comment}) {
    final user = AuthService.to.currentUser.value;
    if (!AuthService.to.isLoggedIn.value || user == null) {
      Get.snackbar(
        'Masuk Diperlukan',
        'Silakan masuk terlebih dahulu untuk menulis ulasan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(Routes.LOGIN);
      return false;
    }
    if (comment.trim().isEmpty) {
      Get.snackbar(
        'Ulasan Kosong',
        'Tulis komentar ulasan Anda terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    reviews.insert(
      0,
      ReviewModel(
        name: user.name,
        avatarColor: AppColors.accentBlue,
        rating: rating,
        timeAgo: 'Baru saja',
        comment: comment.trim(),
        likes: 0,
      ),
    );
    return true;
  }
}