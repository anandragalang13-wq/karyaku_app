import 'package:flutter_test/flutter_test.dart';

import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/data/models/book_model_extension.dart';
import 'package:karyaku_app/app/data/novel_chapters.dart';

void main() {
  group('Konten karya unik dari database', () {
    test('BookModel membawa kolom content apa adanya dari database', () {
      final book = BookModelExtension.fromJson({
        'id': 'b-1',
        'title': 'Bumi Manusia',
        'author': 'Pramoedya Ananta Toer',
        'content': '1|HBS Batavia\n\nIsi bab pertama yang unik.\n\n[[BAB]]\n\n'
            '2|Annelies\n\nIsi bab kedua yang juga unik.',
      });

      expect(book.content, contains('HBS Batavia'));
      expect(book.content, contains('Annelies'));
    });

    test('forBook TIDAK mengembalikan novel yang sama untuk judul lain', () {
      // Dulu semua judul mendapat 5 bab "Laut Bercerita" (isi seragam).
      expect(NovelContent.forBook('Bumi Manusia'), isEmpty);
      expect(NovelContent.forBook('Filosofi Kopi'), isEmpty);
      expect(NovelContent.forBook(null), isEmpty);

      // Judul yang memang punya konten lokal tetap mendapatkannya.
      expect(NovelContent.forBook('Laut Bercerita'), hasLength(5));
      expect(NovelContent.forBook(' Laut Bercerita '), hasLength(5));
    });

    test('dua karya dengan content berbeda menghasilkan bab berbeda', () {
      BookModel book(String id, String content) => BookModelExtension.fromJson({
            'id': id,
            'title': 'Karya $id',
            'author': 'Penulis',
            'content': content,
          });

      final a = book(
          'a', '1|Pembuka\n\nIsi karya pertama yang khas.\n\n[[BAB]]\n\n'
              '2|Penutup\n\nAkhir cerita pertama.');
      final b = book('b', '1|Satu-satunya\n\nPuisi milik karya kedua.');

      expect(a.content, isNot(b.content));
      expect(a.content, contains('karya pertama'));
      expect(b.content, contains('karya kedua'));
    });
  });
}
