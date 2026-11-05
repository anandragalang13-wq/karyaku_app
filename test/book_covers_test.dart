import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karyaku_app/app/data/book_covers.dart';
import 'package:karyaku_app/app/data/models/book_model.dart';
import 'package:karyaku_app/app/data/mock_data.dart';

void main() {
  test('foto cover yang tersedia ada semua di assets/images', () {
    expect(BookCovers.all, hasLength(7));
    for (final path in BookCovers.all) {
      expect(path, startsWith('assets/images/'));
    }
  });

  test('judul buku yang dikenal mendapat foto cover yang cocok', () {
    expect(BookCovers.forTitle('Laut Bercerita'), BookCovers.lautBercerita);
    expect(BookCovers.forTitle('bumi manusia'), BookCovers.bumiManusia);
    expect(BookCovers.forTitle('Filosofi Kopi'), BookCovers.filosofiKopi);
  });

  test('judul buku baru tetap memakai foto dari assets', () {
    final cover = BookCovers.forTitle('Karya Baru Belum Pernah Ada');

    expect(BookCovers.all, contains(cover));

    // Hasilnya konsisten, tidak berubah tiap kali dibuka.
    expect(BookCovers.forTitle('Karya Baru Belum Pernah Ada'), cover);
  });

  test('cover dari Supabase (URL) tidak ditimpa', () {
    const url = 'https://example.com/cover.png';

    expect(BookCovers.resolve(cover: url, title: 'Laut Bercerita'), url);
    expect(BookCovers.resolve(cover: '', title: 'Laut Bercerita'),
        BookCovers.lautBercerita);
    expect(BookCovers.resolve(cover: null, title: null), BookCovers.all.first);
  });

  test('setiap buku selalu punya cover foto', () {
    const booksWithoutCover = BookModel(
      id: 'tanpa-cover',
      title: 'Hujan Bulan Juni',
      author: 'Sapardi Djoko Damono',
      category: 'Puisi',
      rating: 4.8,
      views: 100,
      totalChapters: 1,
      synopsis: '...',
      tags: ['Puisi'],
      coverGradient: [Color(0xFF000000), Color(0xFF333333)],
    );

    expect(booksWithoutCover.coverAsset, BookCovers.hujanBulanJuni);

    // Data contoh yang sudah ada di aplikasi juga ikut terisi.
    expect(MockData.detailBook.coverAsset, BookCovers.lautBercerita);
    expect(MockData.statPopularWorks.every((work) => work.cover.isNotEmpty),
        isTrue);
  });
}
