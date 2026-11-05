import 'package:flutter_test/flutter_test.dart';
import 'package:karyaku_app/app/data/novel_chapters.dart';

void main() {
  group('Konten novel "Laut Bercerita"', () {
    test('memuat tepat 5 bab yang berurutan', () {
      final chapters = NovelContent.lautBercerita;

      expect(chapters, hasLength(5));
      expect(
        chapters.map((c) => c.number),
        [1, 2, 3, 4, 5],
      );
    });

    test('setiap bab punya judul dan isi yang sesuai', () {
      for (final chapter in NovelContent.lautBercerita) {
        expect(chapter.title, isNotEmpty);
        expect(chapter.content.length, greaterThan(400),
            reason: 'Bab ${chapter.number} (${chapter.title}) isinya terlalu pendek');
      }
    });

    test('judul bab menampilkan judul yang diminta pengguna', () {
      final titles =
          NovelContent.lautBercerita.map((c) => c.title).toList();

      expect(titles, contains('Kelompok Winatra'));
      expect(titles, contains('Asmara Jati'));
      expect(titles, contains('Perpustakaan Kota'));
      expect(titles, contains('Surat yang Tak Sampai'));
      expect(titles, contains('Kursi Kosong'));
    });

    test('heading bab berformat "Bab {nomor} {judul}"', () {
      expect(
        NovelContent.lautBercerita.first.heading,
        'Bab 1 Kelompok Winatra',
      );
    });

    test('isi bab 3 membahas perpustakaan (sesuai judul)', () {
      final chapter3 = NovelContent.lautBercerita[2];

      expect(chapter3.number, 3);
      expect(chapter3.title, 'Perpustakaan Kota');
      expect(chapter3.content.toLowerCase(), contains('perpustakaan'));
    });

    test('isi bab 5 membahas kursi kosong (sesuai judul)', () {
      final chapter5 = NovelContent.lautBercerita[4];

      expect(chapter5.number, 5);
      expect(chapter5.title, 'Kursi Kosong');
      expect(chapter5.content.toLowerCase(), contains('kursi'));
      expect(chapter5.content.toLowerCase(), contains('kosong'));
    });
  });
}
