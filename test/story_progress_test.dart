import 'package:flutter_test/flutter_test.dart';
import 'package:karyaku_app/app/data/chapter_content.dart';

void main() {
  group('Progres cerita (ChapterContent)', () {
    test('menghitung jumlah kata sebuah bab', () {
      expect(ChapterContent.wordCount(''), 0);
      expect(ChapterContent.wordCount('   '), 0);
      expect(ChapterContent.wordCount('Malam itu hujan turun'), 4);
      expect(ChapterContent.wordCount('  satu\tdua\n tiga  '), 3);
    });

    test('daftar bab terbaca utuh setelah beberapa bab ditambahkan', () {
      // Bab 1 ditulis lewat form Tambah Karya (tanpa penanda bab).
      var content = 'Isi bab pertama yang panjang sekali untuk latihan.';
      content = ChapterContent.append(
        content: content,
        number: 2,
        title: 'Asmara Jati',
        body: 'Laut menemui adiknya di gerbang sekolah.',
      );

      final chapters = ChapterContent.parse(content);
      expect(chapters, hasLength(2));
      expect(chapters[0].number, 1);
      expect(chapters[0].body, 'Isi bab pertama yang panjang sekali untuk latihan.');
      expect(chapters[1].number, 2);
      expect(chapters[1].title, 'Asmara Jati');
      expect(chapters[1].heading, 'Bab 2 Asmara Jati');
    });

    test('nomor bab berikutnya naik tiap kali bab disimpan', () {
      final empty =
          ChapterContent.nextNumber(content: '', chapterCount: 0);
      expect(empty, 1);

      final content = ChapterContent.append(
        content: 'Isi bab pertama.',
        number: 2,
        title: 'Pembuka',
        body: 'Satu bab sudah tersimpan.',
      );
      expect(
        ChapterContent.nextNumber(content: content, chapterCount: 1),
        3,
      );
    });

    test('progres menampilkan bab terakhir dan total kata', () {
      final content = ChapterContent.append(
        content: 'Satu dua tiga empat lima.',
        number: 2,
        title: 'Lanjutan',
        body: 'Enam tujuh delapan.',
      );

      final chapters = ChapterContent.parse(content);
      final totalWords = chapters.fold<int>(
          0, (sum, c) => sum + ChapterContent.wordCount(c.body));

      expect(chapters.last.number, 2);
      expect(chapters.last.title, 'Lanjutan');
      expect(chapters.last.heading, 'Bab 2 Lanjutan');
      expect(totalWords, 8);
    });

    test('replace mengubah satu bab tanpa menyentuh bab lain', () {
      final content = ChapterContent.append(
        content: 'Isi bab pertama.',
        number: 2,
        title: 'Lanjutan',
        body: 'Enam tujuh delapan.',
      );

      final edited = ChapterContent.replace(
        content: content,
        number: 1,
        title: 'Pembuka',
        body: 'Bab pertama sudah diedit penulis.',
      );

      final chapters = ChapterContent.parse(edited);
      expect(chapters, hasLength(2));
      expect(chapters[0].number, 1);
      expect(chapters[0].title, 'Pembuka');
      expect(chapters[0].body, 'Bab pertama sudah diedit penulis.');
      // Bab lain tetap utuh.
      expect(chapters[1].title, 'Lanjutan');
      expect(chapters[1].body, 'Enam tujuh delapan.');
    });

    test('bab 1 yang diedit tetap terbaca benar setelah disimpan ulang', () {
      // Karya baru: bab 1 masih berupa teks bebas tanpa penanda bab.
      const raw = 'Puisi pertama penulis tentang hujan dan janji.';

      final edited = ChapterContent.replace(
        content: raw,
        number: 1,
        title: 'Hujan Pertama',
        body: 'Hujan turun di atas janji yang belum sempat diucapkan.',
      );

      final chapters = ChapterContent.parse(edited);
      expect(chapters, hasLength(1));
      expect(chapters[0].number, 1);
      expect(chapters[0].title, 'Hujan Pertama');
      expect(chapters[0].heading, 'Bab 1 Hujan Pertama');
      expect(
        chapters[0].body,
        'Hujan turun di atas janji yang belum sempat diucapkan.',
      );

      // Disimpan ulang lagi (edit kedua) dan tetap konsisten.
      final editedTwice = ChapterContent.replace(
        content: edited,
        number: 1,
        title: 'Hujan Pertama',
        body: 'Hujan turun di atas janji yang tak pernah selesai.',
      );
      final again = ChapterContent.parse(editedTwice);
      expect(again, hasLength(1));
      expect(again[0].body, 'Hujan turun di atas janji yang tak pernah selesai.');
      expect(again[0].title, 'Hujan Pertama');
    });

    test('replace pada karya kosong membuat satu bab baru', () {
      final content = ChapterContent.replace(
        content: '',
        number: 1,
        title: 'Pembuka',
        body: 'Mulai cerita dari sini.',
      );

      final chapters = ChapterContent.parse(content);
      expect(chapters, hasLength(1));
      expect(chapters[0].title, 'Pembuka');
      expect(chapters[0].body, 'Mulai cerita dari sini.');
    });
  });
}
