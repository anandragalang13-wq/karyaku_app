/// Satu bab novel yang bisa dibaca di halaman Reader.
class NovelChapter {
  final int number;
  final String title;
  final String content;

  const NovelChapter({
    required this.number,
    required this.title,
    required this.content,
  });

  /// Judul tampilan bab, contoh: "Bab 1 Kelompok Winatra".
  String get heading => 'Bab $number $title';
}

/// Kumpulan konten novel yang tersedia di aplikasi.
class NovelContent {
  NovelContent._();

  /// Novel "Laut Bercerita" — 5 bab utuh.
  static const List<NovelChapter> lautBercerita = [
    NovelChapter(
      number: 1,
      title: 'Kelompok Winatra',
      content: '''
Malam itu, Jakarta seperti tidak pernah benar-benar tidur, melainkan hanya bersembunyi di balik gerimis tipis yang turun tanpa henti sejak senja. Bau tanah basah yang menyengat bercampur dengan aroma jelaga bus, sampah menumpuk, dan asap knalpot menyusup masuk melalui celah-celah papan kayu kontrakan. Namun di dalam ruang sempit berukuran empat kali empat meter di belakang kompleks kampus itu, udara terasa jauh lebih sesak. Ruangan tersebut dipenuhi asap rokok kretek murah yang membumbung pekat, berbaur dengan deru diskusi yang membara tanpa tanda-tanda akan mereda.

Biru Laut duduk tersudut di atas kasur lipat tipis yang sudah aus dan kehilangan bentuknya. Ia memangku setumpuk pamflet stencil yang baru saja selesai dicetak secara sembunyi-sembunyi. Tinta stensilan itu belum sepenuhnya kering, meninggalkan noda-noda hitam di ujung jemarinya dan bau kimia yang menyengat hidung. Sambil menyimak perdebatan di depannya, Laut menyeruput kopi hitam dingin dari cangkir kaleng yang sudah berkarat di bagian pinggirnya, membiarkan rasa pahit itu menahan kantuk yang menggelayut di pelupuk matanya.

"Besok pagi tepat pukul tujuh, kita harus sudah menyebar ini di tiga titik utama," kata Kinan sambil mengetukkan jarinya ke atas meja kayu lapuk. Matanya menatap tajam ke arah tumpukan kertas di pangkuan Laut. "Gerbang depan, kantin humaniora, dan lorong perpustakaan. Jangan sampai ada yang tertinggal. Kalau ada petugas kampus atau aparat berpakaian preman yang mencegat dan bertanya, kita konsisten dengan jawaban awal: ini cuma selebaran undangan diskusi sastra dan apresiasi puisi."

Laut tersenyum tipis, sebuah senyuman samar yang hampir tak terlihat dalam remang lampu minyak. Ia menggelengkan kepala pelan. Di dalam hatinya, ia selalu mengagumi keberanian dan kecerdikan kawan-kawannya di Kelompok Winatra. Mereka selalu punya cara untuk menyulap perlawanan menjadi bentuk-bentuk yang elok. Mereka menyelipkan bait-bait sajak perlawanan, alegori, dan kalimat puisi di antara kritik tajam atas ketidakadilan politik yang sedang terjadi. Seolah-olah kata-kata indah yang dipetik dari sastra klasik bisa menjadi perisai tak kasat mata untuk melindungi diri dari intaian intelijen yang bertebaran di setiap sudut kota. Bagi mereka, sastra bukan cuma soal estetika, melainkan peluru yang dibungkus dengan keindahan.

"Kamu yakin mereka bakal percaya kalau ini cuma acara puisi, Nan?" tanya Alex yang bersandar di tembok rapuh dekat pintu. Wajahnya tampak lelah, dengan lingkaran hitam tebal di bawah matanya setelah dua malam tak tidur menjaga mesin cetak tua. "Kemarin Lazuardi bilang, beberapa orang asing berambut papak sudah mulai sering nongkrong di warung kopi depan gang. Mereka ndak pernah beli apa-apa, cuma duduk seharian sambil memperhatikan siapa saja yang keluar-masuk rumah ini."

"Mau percaya atau tidak, itu masalah mereka," balas Kinan cepat, suaranya mengandung ketegasan yang tak membukakan ruang untuk bantahan. "Tugas kita adalah memastikan gagasan ini sampai ke tangan mahasiswa lain. Kita ndak boleh menyerah sama ketakutan yang sengaja mereka ciptakan."

Namun, kehangatan perdebatan malam itu tak bertahan lama. Tiba-tiba saja, gelisah yang mendalam datang merayap. Suara deru mesin sepeda motor bertransmisi besar yang amat khas terdengar mendekat, lalu berhenti tepat di mulut gang sempit depan kontrakan—berhenti lebih lama dari yang seharusnya. Langkah kaki sepatu bot yang berat menginjak genangan air hujan mulai terdengar melangkah pelan tapi pasti, menuju ke arah pintu mereka.

Seketika itu juga, seluruh dialog terhenti. Hening yang dingin dan mencekam langsung menyergap ruangan. Tak ada satu pun dari mereka yang berani bernapas keras. Anjar, yang mendapat tugas mengawasi area luar di balik selah tirai lusuh dekat jendela, memberi isyarat tangan darurat. Tanpa mengeluarkan suara, ia langsung mematikan lampu minyak.

Ruangan seketika tenggelam dalam kegelapan gulita. Hanya pendar remang dari lampu jalanan jauh di luar yang menyusup tipis melalui celah jendela, memantulkan bayangan-bayangan tubuh mereka yang mematung.

"Laut," bisik Kinan seraya merayap pelan di atas lantai kayu yang berderit. Jemarinya yang dingin dan gemetar langsung menggenggam pergelangan tangan Laut amat erat, menyalurkan getaran ketakutan luar biasa yang coba ia tahan mati-matian. "Kalau malam ini hal terburuk benar-benar terjadi... kalau mereka mendobrak pintu ini dan membawa kita... ingat satu hal."

Kinan mendekatkan wajahnya, bisikannya hampir tenggelam oleh suara detak jantung Laut sendiri. "Jangan pernah sebut nama siapa pun. Jangan pernah akui siapa yang menulis risalah ini. Tutup mulutmu rapat-rapat, apa pun yang mereka lakukan."

Laut mengangguk pelan dalam kegelapan, meski dadanya bergemuruh hebat dan jantungnya berdegup begitu keras hingga terasa berdenyut di sepanjang tenggorokannya. Napasnya tertahan saat mendengar langkah kaki di luar kini berhenti tepat di depan pintu papan kontrakan mereka. Seseorang di luar sana tampak sedang mengamati situasi.

Dalam keheningan mencekam yang rasanya membekukan waktu itu, pikiran Laut melayang jauh melintasi sempitnya kamar tersebut. Ia menatap lurus menembus kegelapan ke arah jendela luar—membayangkan hamparan laut luas yang tak pernah benar-benar bisa ia lihat dari tengah rimba beton kota ini. Laut yang selalu hadir dalam mimpinya: begitu luas, gelap, tenang, namun memeluk erat seluruh rahasia pergerakan dan perjuangan mereka. Sebuah tempat yang terasa seperti satu-satunya muara yang siap menampung segala cerita perjuangan mereka, jika kelak ia dan kawan-kawannya masih diberi kesempatan untuk bernapas, pulang, dan menceritakannya kembali.
''',
    ),
    NovelChapter(
      number: 2,
      title: 'Asmara Jati',
      content: '''
Pukul empat dini hari, gerimis belum juga berhenti. Laut membuka pintu kontrakan perlahan dan membiarkan dirinya berdiri sejenak di ambang, menikmati udara dingin yang menghantam wajahnya seperti pertanyaan yang tak punya jawaban. Di saku jaketnya, amplop cokelat berisi tiga puluh ribu rupiah hasil menjahit seragam anak sekolah tetangga sudah ia lipat dua.

Di ujung gang, sepeda motor tua milik pak pos sudah menunggu. Laut tidak naik motor itu. Ia berjalan kaki sejauh dua kilometer ke halte busway, lalu menumpang dua bus menuju kawasan Menteng, tempat adiknya bersekolah di sebuah SMA favorit negeri.

Asmara Jati berdiri di gerbang sekolah dengan tas ransel yang terlalu besar untuk tubuh mungilnya. Rambutnya digelung asal di sisi kiri, seragamnya digulung sedikit di pergelangan tangan karena kebesaran. Ketika melihat Laut, matanya berbinar sebentar—lalu segera berubah ragu.

"Kak, Ibu tanya-tanya semalam," kata Asmara pelan, menunduk sambil menarik-narik tali ranselnya. "Kenapa Kakak pulang tiap subuh. Aku bilang Kakak bantu menjahit di luar. Ibu diam saja, terus menyiapkan nasi untuk Kakak yang sudah dingin."

Laut menahan napas. Ia ingin berkata segalanya: bahwa malam-malamnya habis untuk mengetik risalah, bahwa tangan kakaknya kotor bukan karena jarum dan benang, bahwa di kota ini orang-orang muda dibungkam dengan cara yang lebih halus daripada kekerasan. Namun ia hanya mengusap kepala adiknya dan berkata, "Nanti Kakak pulang lebih awal. Janji."

"Boleh aku ikut, suatu saat?" tanya Asmara, menatap lurus ke mata kakaknya untuk pertama kalinya.

Laut tersenyum, sayat kecil di tengah keresahan. "Kalau nanti sudah aman, Kakak ajak."

Sepanjang jalan kembali ke kontrakan, ia memikirkan janji itu. Janji yang ia tahu bisa saja tak sempat ditepati. Di kota tempat orang menghilang tanpa suara, setiap janji terasa seperti utang yang dibayar di muka.

Sampai di kamar, Kinan sudah duduk di lantai dengan dua cangkir kopi panas. "Ada kabar dari redaksi mahasiswa di sebelah," kata Kinan tanpa basa-basi. "Mereka mau menerbitkan puisi kita, tapi minta nama dicetak samar. Terlalu takut, mungkin."

"Biar saja," jawab Laut. "YANG penting terbaca."

Kinan mengangguk, lalu menyerahkan selembar kertas garis yang dilipat empat. "Ini dari Alex. Daftar orang yang harus dihubungi kalau kita tidak ada di kampus tiga hari berturut-turut. Simpan di tempat yang tidak akan terbuka oleh siapa pun selain kamu."

Laut menerima kertas itu, membacanya sekali, lalu meremasnya menjadi gulungan kecil. Ia memasukkannya ke dalam kaleng kopi bekas yang sudah dikosongkan, menutup rapat-rapat, dan menyimpannya di balik balok jendela yang sudah lapuk. Di luar, gerimis berubah menjadi hujan yang lebih keras, seolah langit sedang menulis ulang seluruh surat yang tak sempat dikirim.
''',
    ),
    NovelChapter(
      number: 3,
      title: 'Perpustakaan Kota',
      content: '''
Perpustakaan Kota bukan tempat favorit siapa pun pada tahun itu. Gedungnya tua, langit-langitnya tinggi dan lembap, serta lampu-lampunya berdenyut seperti jantung yang kelelahan. Namun bagi Laut, tempat itu adalah satu-satunya ruang di Jakarta yang masih menganggap kata-kata sebagai hal yang serius.

Selama tiga minggu berturut-turut, ia duduk di meja pojok dekat jendela menghadap halaman belakang, membaca arsip koran lama yang disusun dalam rol mikrofilm. Ia mencari tanggal, nama, dan angka—bukti kecil yang bisa disusun seperti teka-teki sampai gambarnya utuh. Di sela-sela itu, ia menulis. Tangan kirinya memegang buku catatan, tangan kanannya menyalin kutipan puisi, dan sesekali ia menggambar garis di margin sebagai kode bahwa paragraf ini harus dikirim ke redaksi.

"Tuan, kami tutup pukul lima."

Pustakawan tua itu hampir tidak pernah menyapa dengan selain kalimat itu. Namun malam itu, ia berhenti di meja Laut, menatap tumpukan kertas di depannya, lalu berkata dengan suara rendah, "Kalau ada yang mencari, bilang saja kamu sedang menyelesaikan skripsi."

Laut terkejut. Ia hanya sempat mengangguk singkat. Si pustakawan sudah berjalan menjauh, kakinya mengetuk lantai kayu dengan irama yang berubah—lebih cepat dari biasanya.

Malam itu pula Laut mengerti bahwa perlawanan tidak selalu berteriak. Kadang ia bersembunyi di balik sikap diam seorang penjaga pintu, di balik lagu yang dinyanyikan terlalu pelan untuk didengar orang lain, di balik selembar kartu perpustakaan yang diulurkan tanpa banyak pertanyaan.

Di halaman belakang, hujan mulai turun lagi. Laut menutup mikrofilm, memasukkan catatannya ke dalam jaket, dan berjalan ke arah pintu samping yang tidak pernah dikunci. Di sana, Alex sudah menunggu dengan sepeda motor bututnya.

"Kamu telat sepuluh menit," kata Alex.

"Aku menemukan sesuatu," balas Laut, menaiki jok belakang. "Bukan nama. Tapi urutan tanggal. Dan urutan itu cocok dengan jadwal rapat yang seharusnya sudah dibubarkan setahun lalu."

Sepeda motor itu meluncur menembus genangan. Di belakang mereka, lampu perpustakaan dimatikan satu per satu, seperti mata yang akhirnya memilih untuk tidak melihat.
''',
    ),
    NovelChapter(
      number: 4,
      title: 'Surat yang Tak Sampai',
      content: '''
Ada satu surat yang tidak pernah Laut kirimkan.

Surat itu ditulis di malam ketika ia sudah tiga hari tidak pulang, ketika badannya panas dan tangannya gemetar, ketika tinta pena membatuk noda di kertas seolah kertas itu juga ikut sakit. Laut menulisnya untuk ibunya, untuk Asmara, dan untuk seseorang yang namanya berulang-ulang di kepalanya namun tak pernah ia sebut di depan kawan-kawannya.

Ibu, begini keadaan kami. Kami tidak sedang bermain-main, dan kami tidak sedang mencari kematian. Kami hanya tidak tahan melihat orang miskin dianggap sebagai kesalahan mereka sendiri. Kalau besok Kakak pulang lebih malam dari biasanya, tolong biarkan lampu dapur menyala.

Ia melipat surat itu, memasukkannya ke dalam amplop, lalu menaruhnya di antara halaman terakhir buku kumpulan puisi yang selalu ia bawa. Esok paginya, buku itu hilang dari atas meja. Laut mencarinya selama dua jam, lalu berhenti, karena ada hal yang lebih penting: seluruh isi kontrakan sudah diobrak-abrik, kasur lipat terbalik, tumpukan pamflet berhamburan basah di lantai, dan kaleng berisi gulungan kertas itu raip.

Yang tersisa hanya sepatu Alex yang tergeletak di tengah ruangan, masih basah oleh hujan semalam.

Laut tidak menangis. Ia hanya duduk di antara puing-puing kecil itu, memunguti satu per satu kertas yang masih terbaca, dan menyusunnya kembali dengan tangan yang pelan sekali, seolah takut kertas itu akan robek lagi kalau terlalu cepat.

Malam harinya, Kinan datang membawa kabar bahwa Alex diperiksa di kantor polisi selama sebelas jam, dan dilepas tanpa surat penahanan. "Mereka tidak menemukan apa-apa," kata Kinan. "Karena tidak ada yang kami simpan di tempat itu sekarang."

Laut mengangguk. Ia tidak bilang bahwa surat untuk ibunya ikut hilang bersama buku itu. Ia tidak bilang bahwa beberapa hal memang lebih baik tidak sampai—karena surat yang tidak sampai kadang melindungi orang yang menerimanya dari kenyataan yang terlalu berat untuk dipegang.

Di beranda kontrakan, hujan turun dengan tenang. Laut berdiri di sana cukup lama, menatap langit yang tidak menjawab apa-apa.
''',
    ),
    NovelChapter(
      number: 5,
      title: 'Kursi Kosong',
      content: '''
Dua dekade kemudian, Asmara Jati masih menyiapkan satu porsi nasi tambahan setiap malam Minggu.

Meja makan di rumah kontrakan yang sama kini sudah diperbaiki dua kali, kursinya sudah diganti tiga kali, namun satu kursi di pojok dekat jendela tidak pernah dipindahkan. Catnya mengelupas di sudut kiri atas—bekas jemari seorang kakak yang suka mengetuk meja ketika berpikir.

Asmara tidak pernah bertanya kepada ibunya mengapa porsi itu selalu ada. Ia hanya memastikan sendoknya bersih, menutup piringnya, dan berkata pelan sebelum kembali ke kamar, "Nanti juga dimakan, Ma."

Ia tahu porsi itu tidak akan pernah dimakan. Ia juga tahu bahwa menghapus kebiasaan itu berarti menghapus satu-satunya cara keluarga ini untuk tetap berbicara tentang orang yang hilang tanpa harus menyebutnya.

Malam Minggu itu, lampu meja makan menyala jam sembilan seperti biasa. Asmara membuka pintu untuk tamu yang tak diundang: seorang perempuan tua bertopi anyaman yang menenteng map berisi fotokopi. "Saya dari arsip," kata perempuan itu. "Kami sedang menyusun daftar. Nama adikmu ada di sini, kalau Anda berkenan memeriksanya."

Asmara menerima map itu dengan dua tangan. Di dalamnya: tanggal, tempat, dan satu kalimat pendek yang tidak menjelaskan apa pun tentang bagaimana keadaan kakaknya sekarang, hanya tentang bagaimana keadaan kota ketika kakaknya pergi.

Ia membaca kalimat itu berulang-ulang sampai matanya lelah, lalu meletakkannya di kursi kosong itu—persis di tempat selembar kertas biasanya ditinggalkan oleh seorang kakak yang selalu pulang membawa berita dunia.

Di dapur, ibunya mematikan kompor. Untuk pertama kalinya sejak dua puluh tahun, porsi nasi itu tidak dihangatkan. Ia duduk di kursi sebelahnya dan berkata, "Sudah waktunya kita makan berdua, Ndra."

Asmara mengangguk. Ia mengambil piringnya, lalu piring di kursi kosong itu ikut ia ambil—karena suatu hari nanti, katanya dalam hati, kursi itu harus kembali terisi.

Di luar, hujan bulan juni turun lagi, rahasia seperti biasa, dan tidak seorang pun menahannya.
''',
    ),
  ];

  /// Konten bab untuk sebuah buku.
  ///
  /// Selama belum ada penulisan bab per judul, semua buku yang dibuka di
  /// halaman Reader memakai novel contoh [lautBercerita] — sesuai perilaku
  /// lama aplikasi yang hanya menampilkan satu teks contoh untuk semua buku.
  static List<NovelChapter> forBook(String? title) => lautBercerita;
}
