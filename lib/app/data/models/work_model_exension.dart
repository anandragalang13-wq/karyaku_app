import 'package:flutter/material.dart';

import 'book_model.dart';
import 'work_model.dart';

/// Konversi [WorkModel] (sumber data karya di halaman Beranda) menjadi
/// [BookModel], supaya buku yang tampil di Perpustakaan (Histori & Koleksi)
/// dan Pencarian selalu sinkron dengan buku yang ada di Beranda.
extension WorkModelToBookModel on WorkModel {
  static const Map<String, String> _authorNames = {
    'leila-s-chudori': 'Leila S. Chudori',
    'pramoedya-ananta-toer': 'Pramoedya Ananta Toer',
    'sapardi-djoko-damono': 'Sapardi Djoko Damono',
    'dewi-lestari': 'Dee Lestari',
    'henry-manampiring': 'Henry Manampiring',
    'anandra-galang': 'Anandra Galang',
  };

  String get _authorDisplayName {
    final name = authorName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final known = _authorNames[authorId];
    if (known != null) return known;
    // authorId sudah berupa nama lengkap, mis. "Sapardi Djoko Damono"
    if (authorId.contains(' ')) return authorId;
    // fallback: ubah slug "nama-penulis" menjadi "Nama Penulis"
    return authorId
        .split('-')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  List<Color> _gradientForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return const [Color(0xFF667eea), Color(0xFF764ba2)];
      case 'puisi':
        return const [Color(0xFFf093fb), Color(0xFFf5576c)];
      case 'cerpen':
        return const [Color(0xFF4facfe), Color(0xFF00f2fe)];
      default:
        return const [Color(0xFF667eea), Color(0xFF764ba2)];
    }
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'novel':
        return Icons.menu_book_rounded;
      case 'puisi':
        return Icons.favorite_rounded;
      case 'cerpen':
        return Icons.description_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  /// Mengonversi karya ini menjadi [BookModel] agar bisa dipakai oleh
  /// widget & halaman yang masih berbasis BookModel (Perpustakaan,
  /// Pencarian, Detail Buku).
    BookModel toBookModel() {
    final category = type.label;

    return BookModel(
      id: id,
      title: title,
      author: _authorDisplayName,
      category: category,
      rating: rating,
      views: views,
      totalChapters: chapterCount,
      currentChapter: 0,
      synopsis: synopsis ?? content,
      tags: tags,
      status: 'Ongoing',
      progress: 0.0,
      // Kalau cover kosong, BookModel.coverAsset otomatis memakai foto
      // dari folder assets berdasarkan judul.
      coverAsset: cover,
      coverGradient: _gradientForCategory(category),
      coverIcon: _iconForCategory(category),
    );
  }
}