import 'package:flutter_test/flutter_test.dart';
import 'package:karyaku_app/app/data/chapter_content.dart';

void main() {
  group('ChapterContent', () {
    test('isi tanpa penanda bab dianggap satu bab (Bab 1)', () {
      final blocks = ChapterContent.parse('Draft belum selesai...');

      expect(blocks, hasLength(1));
      expect(blocks.first.number, 1);
      expect(blocks.first.title, isEmpty);
      expect(blocks.first.body, 'Draft belum selesai...');
      expect(blocks.first.heading, 'Bab 1');
    });

    test('append menambah blok bab di akhir isi karya', () {
      final content = ChapterContent.append(
        content: 'Isi bab pertama.',
        number: 2,
        title: 'Malam Panjang',
        body: 'Hujan turun sejak senja.',
      );

      final blocks = ChapterContent.parse(content);
      expect(blocks, hasLength(2));
      expect(blocks[0].body, 'Isi bab pertama.');
      expect(blocks[1].number, 2);
      expect(blocks[1].title, 'Malam Panjang');
      expect(blocks[1].body, 'Hujan turun sejak senja.');
      expect(blocks[1].heading, 'Bab 2 Malam Panjang');
    });

    test('isi karya tetap utuh setelah bab ditambahkan berkali-kali', () {
      var content = 'Bab pertama.';
      for (var i = 2; i <= 4; i++) {
        content = ChapterContent.append(
          content: content,
          number: i,
          title: 'Bab $i',
          body: 'Isi bab $i.',
        );
      }

      final blocks = ChapterContent.parse(content);
      expect(blocks.map((b) => b.number), [1, 2, 3, 4]);
      expect(blocks.first.body, 'Bab pertama.');
      expect(blocks.last.body, 'Isi bab 4.');
    });

    test('nomor bab berikutnya mengikuti jumlah bab yang sudah tertulis', () {
      expect(
        ChapterContent.nextNumber(content: 'Baru satu bab.', chapterCount: 1),
        2,
      );
      expect(
        ChapterContent.nextNumber(content: 'Baru satu bab.', chapterCount: 5),
        6,
      );
    });

    test('jumlah bab tidak pernah lebih kecil dari total_chapters', () {
      expect(
        ChapterContent.countOf(content: 'Satu blok.', chapterCount: 28),
        28,
      );

      var content = 'Bab pertama.';
      for (var i = 2; i <= 3; i++) {
        content = ChapterContent.append(
          content: content,
          number: i,
          title: 'Bab $i',
          body: 'Isi bab $i.',
        );
      }
      expect(ChapterContent.countOf(content: content, chapterCount: 1), 3);
    });
  });
}
