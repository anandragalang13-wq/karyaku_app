import 'package:get/get.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/book_model.dart';
import '../../../theme/app_theme.dart';

/// Controller halaman membaca (Reader) beserta panel "Pengaturan Buku"
/// untuk mengatur tema baca, jenis huruf, dan ukuran font.
class ReaderController extends GetxController {
  late final BookModel book;

  final Rx<ReaderTheme> theme = ReaderTheme.sepia.obs;
  final Rx<ReaderFont> font = ReaderFont.merriweather.obs;
  final RxDouble fontSize = 17.0.obs;

  static const String sampleChapterTitle = 'Lentera di Balik Kabut';
  static const String sampleChapterText = '''
Kabut tebal menyelimuti desa itu, seolah-olah berniat menyembunyikan segala rahasia yang terpendam selama puluhan tahun. Angin malam berhembus dingin, membawa serta aroma pinus basah dan sesuatu yang usang—seperti kertas tua yang lama terkurung dalam peti mati kayu.

Baskara merapatkan jaketnya, mengusap kedua tangan yang mulai kebas. Matanya awas menatap jalan setapak berbatu di depannya. Di ujung jalan, sebuah lentera tua tampak bergoyang ditiup angin, memancarkan cahaya kekuningan yang redup. Itulah tujuannya malam ini.

"Kakek bilang, jangan pernah mendekati rumah itu setelah matahari terbenam," suara lirih Nimas kembali terngiang di telinganya. Namun rasa ingin tahu mengalahkan rasa takut yang sedari tadi merayap di dadanya.

Ia melangkah maju. Sepatunya menginjak ranting kering, suaranya terdengar begitu keras di tengah keheningan malam yang mencekam. Tiba-tiba, cahaya lentera itu berkedip... lalu padam.

Kegelapan menyergap sekejap. Baskara menahan napas. Terdengar suara derit pintu kayu terbuka perlahan dari arah depan.

"Siapa di sana?" teriaknya, mencoba menyembunyikan getar dalam suaranya. Tidak ada jawaban, hanya suara angin yang menderu membawa pesan dari masa lalu.
''';

  @override
  void onInit() {
    super.onInit();
    book = Get.arguments is BookModel ? Get.arguments as BookModel : MockData.detailBook;
  }

  void setTheme(ReaderTheme t) => theme.value = t;
  void setFont(ReaderFont f) => font.value = f;
  void setFontSize(double v) => fontSize.value = v;
}
