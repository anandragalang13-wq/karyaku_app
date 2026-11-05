/// Sumber tunggal foto cover buku yang tersimpan di folder `assets/images/`.
///
/// Semua buku yang tampil di aplikasi wajib memakai foto dari daftar ini,
/// supaya tidak ada lagi buku yang tampil sebagai kotak gradient kosong.
///
/// Cara pemakaian:
/// - [forTitle]     → ambil foto berdasarkan judul buku (data mock).
/// - [resolve]      → ambil cover sebuah buku; kalau field cover-nya kosong
///                    (mis. kolom `cover_asset` di Supabase belum diisi),
///                    otomatis diisi foto dari [all].
class BookCovers {
  const BookCovers._();

  static const String _folder = 'assets/images/';

  static const String lautBercerita = '${_folder}Laut_Bercerita.png';
  static const String bumiManusia = '${_folder}Bumi_Manusia.png';
  static const String akuIngin = '${_folder}Aku_Ingin.png';
  static const String filosofiKopi = '${_folder}Filosofi_Kopi.png';
  static const String filosofiTeras = '${_folder}Filosofi_Teras.png';
  static const String hujanBulanJuni = '${_folder}Hujan_Bulan_Juni.png';
  static const String senjaDiPelantara = '${_folder}Senja_di_Pelantara.png';

  /// Semua foto cover yang tersedia di `assets/images/`.
  static const List<String> all = [
    lautBercerita,
    bumiManusia,
    akuIngin,
    filosofiKopi,
    filosofiTeras,
    hujanBulanJuni,
    senjaDiPelantara,
  ];

  /// Pemetaan judul buku (huruf kecil) ke foto cover-nya.
  static const Map<String, String> byTitle = {
    'laut bercerita': lautBercerita,
    'bumi manusia': bumiManusia,
    'aku ingin': akuIngin,
    'filosofi kopi': filosofiKopi,
    'filosofi teras': filosofiTeras,
    'hujan bulan juni': hujanBulanJuni,
    'senja di pelantara': senjaDiPelantara,
  };

  /// Foto cover untuk [title]. Judul yang tidak ada di [byTitle] tetap
  /// mendapat foto dari [all], dipilih dari jumlah huruf judul supaya
  /// hasilnya selalu sama setiap kali aplikasi dibuka.
  static String forTitle(String? title) {
    final trimmed = title?.trim() ?? '';
    if (trimmed.isEmpty) return all.first;

    final exact = byTitle[trimmed.toLowerCase()];
    if (exact != null) return exact;

    var seed = 0;
    for (final unit in trimmed.codeUnits) {
      seed += unit;
    }
    return all[seed % all.length];
  }

  /// Menentukan cover akhir sebuah buku:
  /// 1. cover sudah ada (URL Supabase / path asset) → dipakai apa adanya.
  /// 2. cover kosong → diisi foto dari assets berdasarkan judul.
  static String resolve({String? cover, String? title}) {
    final existing = cover?.trim() ?? '';
    if (existing.isNotEmpty) return existing;
    return forTitle(title);
  }
}
