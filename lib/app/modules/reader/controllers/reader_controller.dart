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

  static const int sampleChapterNumber = 1;
  static const String sampleChapterTitle = 'Kelompok Winatra';
  static const String sampleChapterText = '''
Malam itu, Jakarta seperti tidak pernah benar-benar tidur, melainkan hanya bersembunyi di balik gerimis tipis yang turun tanpa henti sejak senja. Bau tanah basah yang menyengat bercampur dengan aroma jelaga bus, sampah menumpuk, dan asap knalpot menyusup masuk melalui celah-celah papan kayu kontrakan. Namun di dalam ruang sempit berukuran empat kali empat meter di belakang kompleks kampus itu, udara terasa jauh lebih sesak. Ruangan tersebut dipenuhi asap rokok kretek murah yang membumbung pekat, berbaur dengan deru diskusi yang membara tanpa tanda-tiga akan mereda.

Biru Laut duduk tersudut di atas kasur lipat tipis yang sudah aus dan kehilangan bentuknya. Ia memangku setumpuk pamflet stencil yang baru saja selesai dicetak secara sembunyi-sembunyi. Tinta stensilan itu belum sepenuhnya kering, meninggalkan noda-noda hitam di ujung jemarinya dan bau kimia yang menyengat hidung. Sambil menyimak perdebatan di depannya, Laut menyeruput kopi hitam dingin dari cangkir kaleng yang sudah berkarat di bagian pinggirnya, membiarkan rasa pahit itu menahan kantuk yang menggelayut di pelupuk matanya.

"Besok pagi tepat pukul tujuh, kita harus sudah menyebar ini di tiga titik utama," kata Kinan sambil mengetukkan jarinya ke atas meja kayu lapuk. Matanya menatap tajam ke arah tumpukan kertas di pangkuan Laut. "Gerbang depan, kantin humaniora, dan lorong perpustakaan. Jangan sampai ada yang tertinggal. Kalau ada petugas kampus atau aparat berpakaian preman yang mencegat dan bertanya, kita konsisten dengan jawaban awal: ini cuma selebaran undangan diskusi sastra dan apresiasi puisi."

Laut tersenyum tipis, sebuah senyuman samar yang hampir tak terlihat dalam remang lampu minyak. Ia menggelengkan kepala pelan. Di dalam hatinya, ia selalu mengagumi keberanian dan kecerdikan kawan-kawannya di Kelompok Winatra. Mereka selalu punya cara untuk menyulap perlawanan menjadi bentuk-bentuk yang elok. Mereka menyelipkan bait-bait sajak perlawanan, alegori, dan kalimat puisi di antara kritik tajam atas ketidakadilan politik yang sedang terjadi. Seolah-olah kata-kata indah yang dipetik dari sastra klasik bisa menjadi perisai tak kasat mata untuk melindungi diri dari intaian intelijen yang bertebaran di setiap sudut kota. Bagi mereka, sastra bukan cuma soal estetika, melainkan peluru yang dibungkus dengan keindahan.

"Kamu yakin mereka bakal percaya kalau ini cuma acara puisi, Nan?" tanyak Alex yang bersandar di tembok rapuh dekat pintu. Wajahnya tampak lelah, dengan lingkaran hitam tebal di bawah matanya setelah dua malam tak tidur menjaga mesin cetak tua. "Kemarin Lazuardi bilang, beberapa orang asing berambut papak sudah mulai sering nongkrong di warung kopi depan gang. Mereka ndak pernah beli apa-apa, cuma duduk seharian sambil memperhatikan siapa saja yang keluar-masuk rumah ini."

"Mau percaya atau tidak, itu masalah mereka," balas Kinan cepat, suaranya mengandung ketegasan yang tak membukakan ruang untuk bantahan. "Tugas kita adalah memastikan gagasan ini sampai ke tangan mahasiswa lain. Kita ndak boleh menyerah sama ketakutan yang sengaja mereka ciptakan."

Namun, kehangatan perdebatan malam itu tak bertahan lama. Tiba-tiba saja, gelisah yang mendalam datang merayap. Suara deru mesin sepeda motor bertransmisi besar yang amat khas terdengar mendekat, lalu berhenti tepat di mulut gang sempit depan kontrakan—berhenti lebih lama dari yang seharusnya. Langkah kaki heavy-duty yang berat dan menginjak genangan air hujan mulai terdengar melangkah pelan tapi pasti, menuju ke arah pintu mereka.

Seketika itu juga, seluruh dialog terhenti. Hening yang dingin dan mencekam langsung menyergap ruangan. Tak ada satu pun dari mereka yang berani bernapas keras. Anjar, yang mendapat tugas mengawasi area luar di balik selah tirai lusuh dekat jendela, memberi isyarat tangan darurat. Tanpa mengeluarkan suara, ia langsung mematikan lampu minyak.

Ruangan seketika tenggelam dalam kegelapan gulita. Hanya pendar remang dari lampu jalanan jauh di luar yang menyusup tipis melalui celah jendela, memantulkan bayangan-bayangan tubuh mereka yang mematung.

"Laut," bisik Kinan seraya merayap pelan di atas lantai kayu yang berderit. Jemarinya yang dingin dan gemetar langsung menggenggam pergelangan tangan Laut amat erat, menyalurkan getaran ketakutan luar biasa yang coba ia tahan mati-matian. "Kalau malam ini hal terburuk benar-benar terjadi... kalau mereka mendobrak pintu ini dan membawa kita... ingat satu hal."

Kinan mendekatkan wajahnya, bisikannya hampir tenggelam oleh suara detak jantung Laut sendiri. "Jangan pernah sebut nama siapa pun. Jangan pernah akui siapa yang menulis risalah ini. Tutup mulutmu rapat-rapat, apa pun yang mereka lakukan."

Laut mengangguk pelan dalam kegelapan, meski dadanya bergemuruh hebat dan jantungnya berdegup begitu keras hingga terasa berdenyut di sepanjang tenggorokannya. Napasnya tertahan saat mendengar langkah kaki di luar kini berhenti tepat di depan pintu papan kontrakan mereka. Seseorang di luar sana tampak sedang mengamati situasi.

Dalam keheningan mencekam yang rasanya membekukan waktu itu, pikiran Laut melayang jauh melintasi sempitnya kamar tersebut. Ia menatap lurus menembus kegelapan ke arah jendela luar—membayangkan hamparan laut luas yang tak pernah benar-benar bisa ia lihat dari tengah rimba beton kota ini. Laut yang selalu hadir dalam mimpinya: begitu luas, gelap, tenang, namun memeluk erat seluruh rahasia pergerakan dan perjuangan mereka. Sebuah tempat yang terasa seperti satu-satunya muara yang siap menampung segala cerita perjuangan mereka, jika kelak ia dan kawan-kawannya masih diberi kesempatan untuk bernapas, pulang, dan menceritakannya kembali.
''';
  @override
  void onInit() {
    super.onInit();
    book = Get.arguments is BookModel
        ? Get.arguments as BookModel
        : MockData.detailBook;
  }

  void setTheme(ReaderTheme t) => theme.value = t;
  void setFont(ReaderFont f) => font.value = f;
  void setFontSize(double v) => fontSize.value = v;
}
