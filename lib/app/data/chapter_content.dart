/// Satu blok bab milik sebuah karya.
class ChapterBlock {
  final int number;
  final String title;
  final String body;

  const ChapterBlock({
    required this.number,
    required this.title,
    required this.body,
  });

  /// Judul tampilan bab, contoh: "Bab 3 Malam Panjang".
  String get heading =>
      title.isEmpty ? 'Bab $number' : 'Bab $number ${title.trim()}';
}

/// Penyimpanan bab pada kolom `books.content`.
///
/// Karya disimpan sebagai kumpulan blok bab yang dipisahkan [separator],
/// sehingga penulis bisa menambah bab baru tanpa memerlukan tabel terpisah
/// dan tetap aman dengan kebijakan RLS yang sudah ada (penulis boleh
/// mengubah `content`, `total_chapters`, dan `current_chapter` karyanya
/// sendiri selama statusnya masih draft/pending).
class ChapterContent {
  ChapterContent._();

  /// Pemisah antar blok bab.
  static const String separator = '\n\n[[BAB]]\n\n';

  /// Format sebuah blok: `<nomor>|<judul>\n\n<isi>`.
  static String _block({
    required int number,
    required String title,
    required String body,
  }) =>
      '$number|${title.trim()}\n\n${body.trim()}';

  /// Membaca seluruh bab dari isi karya.
  ///
  /// Blok pertama dianggap Bab 1: bila belum pernah diedit, seluruh teks
  /// dianggap isi bab tanpa penanda; bila sudah pernah diedit, ia memakai
  /// format header `<nomor>|<judul>` seperti blok lainnya.
  static List<ChapterBlock> parse(String content) {
    final chunks = content.split(separator);
    final blocks = <ChapterBlock>[];

    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i].trim();
      if (chunk.isEmpty) continue;

      if (i == 0 && !_looksLikeHeader(chunk)) {
        blocks.add(ChapterBlock(number: 1, title: '', body: chunk));
        continue;
      }

      final newline = chunk.indexOf('\n');
      final header = newline == -1 ? chunk : chunk.substring(0, newline);
      final body = newline == -1 ? '' : chunk.substring(newline + 1).trim();
      final parts = header.split('|');

      blocks.add(ChapterBlock(
        number: int.tryParse(parts.first.trim()) ?? blocks.length + 1,
        title: parts.length > 1 ? parts.sublist(1).join('|').trim() : '',
        body: body,
      ));
    }

    return blocks;
  }

  /// Apakah sebuah blok memakai format header `<nomor>|<judul>`?
  static bool _looksLikeHeader(String chunk) {
    final newline = chunk.indexOf('\n');
    final header = newline == -1 ? chunk : chunk.substring(0, newline);
    final pipe = header.indexOf('|');
    if (pipe <= 0) return false;
    return int.tryParse(header.substring(0, pipe).trim()) != null;
  }

  /// Menambah satu blok bab baru di akhir isi karya.
  static String append({
    required String content,
    required int number,
    required String title,
    required String body,
  }) {
    final base = content.trimRight();
    final block = _block(number: number, title: title, body: body);
    return base.isEmpty ? block : '$base$separator$block';
  }

  /// Menulis ulang satu bab (edit judul/isi) tanpa menyentuh bab lain.
  ///
  /// Berguna untuk fitur "Edit Karya": penulis mengubah teks/puisi bab
  /// sebelumnya, lalu seluruh isi karya disusun ulang dari daftar bab.
  static String replace({
    required String content,
    required int number,
    required String title,
    required String body,
  }) {
    final blocks = parse(content);
    if (blocks.isEmpty) {
      return _block(number: number, title: title, body: body);
    }

    final rebuilt = [
      for (final block in blocks)
        block.number == number
            ? _block(number: number, title: title, body: body)
            : _block(
                number: block.number,
                title: block.title,
                body: block.body,
              ),
    ];
    return rebuilt.join(separator);
  }

  /// Nomor bab berikutnya, mengacu pada jumlah bab yang sudah tertulis
  /// maupun angka `total_chapters` (mana yang lebih besar).
  static int nextNumber({
    required String content,
    required int chapterCount,
  }) {
    final written = parse(content).length;
    return (written > chapterCount ? written : chapterCount) + 1;
  }

  /// Jumlah bab sebuah karya (fallback ke [chapterCount] bila lebih besar).
  static int countOf({
    required String content,
    required int chapterCount,
  }) {
    final written = parse(content).length;
    return written > chapterCount ? written : chapterCount;
  }

  /// Jumlah kata pada sebuah teks (untuk ringkasan progres penulisan).
  static int wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
