import 'package:flutter/material.dart';
import 'models/book_model.dart';
import 'models/review_model.dart';
import 'models/user_model.dart';
import 'models/stat_models.dart';

/// Sumber data contoh (mock) yang mensimulasikan data dari backend/API.
/// Pada implementasi nyata, kelas ini bisa diganti dengan pemanggilan
/// service/repository yang mengambil data dari REST API atau database.
class MockData {
  MockData._();

  static const UserModel currentUser = UserModel(
    id: 'anandra-galang',
    name: 'Anandra Galang',
    email: 'anandra@karyaku.com',
    badge: 'Pembaca Setia',
    karyaDibaca: 42,
    koleksi: 15,
    pengikut: 1200,
  );

  static final BookModel featuredBook = BookModel(
    id: 'laut-bercerita',
    title: 'Laut Bercerita',
    author: 'Leila S. Chudori',
    category: 'Novel',
    rating: 4.9,
    views: 245000,
    totalChapters: 28,
    currentChapter: 18,
    synopsis:
        'Sebuah kisah tentang persahabatan, cinta, dan perjuangan di tengah '
        'gejolak politik Indonesia akhir era 1990-an, dituturkan lewat sudut '
        'pandang yang menyayat hati.',
    tags: const ['Romansa', 'Novel'],
    status: 'Ongoing',
    progress: 0.65,
    coverGradient: const [Color(0xFF1F3A5F), Color(0xFF0B1526)],
    coverIcon: Icons.waves_rounded,
  );

  static final List<String> homeTags = [
    'Romansa',
    'Cerpen',
    'Puisi',
    'Novel',
  ];

  static final List<BookModel> popularBooks = [
    BookModel(
      id: 'bumi-manusia',
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      category: 'Novel',
      rating: 4.9,
      views: 512000,
      totalChapters: 40,
      currentChapter: 32,
      synopsis:
          'Kisah Minke, seorang pribumi terpelajar di masa kolonial Belanda, '
          'yang bergulat dengan cinta, identitas, dan ketidakadilan.',
      tags: const ['Sejarah', 'Novel', 'Klasik'],
      status: 'Ongoing',
      progress: 0.8,
      coverGradient: const [Color(0xFF3B4E6B), Color(0xFF16233A)],
      coverIcon: Icons.public_rounded,
    ),
    BookModel(
      id: 'aku-ini-binatang-jalang',
      title: 'Aku Ini Binatang Jalang',
      author: 'Chairil Anwar',
      category: 'Puisi',
      rating: 4.8,
      views: 187000,
      totalChapters: 12,
      currentChapter: 5,
      synopsis:
          'Kumpulan puisi kontemporer karya Luna Adriana, merefleksikan '
          'jiwa yang bebas dan menolak tunduk pada keadaan.',
      tags: const ['Puisi', 'Kontemporer'],
      status: 'Ongoing',
      progress: 0.4,
      coverGradient: const [Color(0xFFB9C6D6), Color(0xFF7C8AA0)],
      coverIcon: Icons.auto_awesome_rounded,
    ),
    BookModel(
      id: 'cerita-dari-jendela-kota',
      title: 'Cerita dari Jendela Kota',
      author: 'Dian Prasetyo',
      category: 'Cerpen',
      rating: 4.6,
      views: 98000,
      totalChapters: 8,
      currentChapter: 8,
      synopsis:
          'Kumpulan cerita pendek tentang kehidupan warga kota yang penuh '
          'warna, lucu, sekaligus menyentuh.',
      tags: const ['Cerpen', 'KehidupanKota'],
      status: 'Selesai',
      progress: 1.0,
      coverGradient: const [Color(0xFFE0A544), Color(0xFFB9762A)],
      coverIcon: Icons.location_city_rounded,
    ),
    BookModel(
      id: 'sekar-malam',
      title: 'Sekar Malam',
      author: 'Rangga Wirawan',
      category: 'Novel',
      rating: 4.7,
      views: 143000,
      totalChapters: 24,
      currentChapter: 10,
      synopsis:
          'Sebuah novel misteri kelam yang mengungkap rahasia keluarga di '
          'sebuah kota kecil tepi pantai.',
      tags: const ['Novel', 'Misteri'],
      status: 'Ongoing',
      progress: 0.3,
      coverGradient: const [Color(0xFF152642), Color(0xFF0A1220)],
      coverIcon: Icons.nightlight_round,
    ),
  ];

  static final BookModel detailBook = BookModel(
    id: 'senja-di-pelataran',
    title: 'Senja di Pelataran',
    author: 'Anwar Hidayat',
    category: 'Cerpen',
    rating: 4.7,
    views: 667000,
    totalChapters: 32,
    currentChapter: 12,
    synopsis:
        'Di sebuah desa kecil di lereng Gunung Merapi, kehidupan berjalan '
        'dengan tenang sampai sebuah surat dari masa lalu membuka luka lama '
        'keluarga Suryo. Senja itu, pelataran rumah joglo menjadi saksi bisu '
        'pertemuan yang telah lama dinanti, membawa kembali kenangan yang '
        'selama ini terkubur dalam diam.',
    tags: const ['Cerpen', 'Sastra', 'Keluarga'],
    status: 'Ongoing',
    progress: 0.37,
    coverGradient: const [Color(0xFF2B3A55), Color(0xFF0E1626)],
    coverIcon: Icons.landscape_rounded,
  );

  static final List<ReviewModel> reviews = [
    const ReviewModel(
      name: 'Budi Santoso',
      avatarColor: Color(0xFF1D5FBF),
      rating: 5,
      timeAgo: '2 jam yang lalu',
      comment:
          'Sangat menyentuh! Gaya bahasanya puitis tapi mudah dipahami. '
          'Plot twist di akhir bab 5 benar-benar tidak terduga.',
      likes: 24,
    ),
    const ReviewModel(
      name: 'Rina Melati',
      avatarColor: Color(0xFFE0A544),
      rating: 4,
      timeAgo: '1 hari yang lalu',
      comment:
          'Penggambaran desanya sangat detail, saya merasa seperti kembali '
          'ke kampung halaman. Namun alurnya sedikit lambat di awal.',
      likes: 8,
    ),
  ];

  static final List<BookModel> historyBooks = [
    BookModel(
      id: 'laut-bercerita-h',
      title: 'Laut Bercerita',
      author: 'Leila S. Chudori',
      category: 'Novel',
      rating: 4.9,
      views: 245000,
      totalChapters: 28,
      currentChapter: 18,
      synopsis: featuredBook.synopsis,
      tags: const ['Novel'],
      status: 'Ongoing',
      progress: 0.65,
      coverGradient: const [Color(0xFF1F3A5F), Color(0xFF0B1526)],
      coverIcon: Icons.waves_rounded,
    ),
    BookModel(
      id: 'hujan-bulan-juni-h',
      title: 'Hujan Bulan Juni',
      author: 'Sapardi Djoko Damono',
      category: 'Puisi',
      rating: 4.9,
      views: 320000,
      totalChapters: 20,
      currentChapter: 20,
      synopsis:
          'Kumpulan puisi tentang cinta yang tabah dan bijaksana, seperti '
          'hujan bulan Juni yang dirahasiakan rintik rindunya.',
      tags: const ['Puisi'],
      status: 'Selesai',
      progress: 1.0,
      coverGradient: const [Color(0xFFCED9E6), Color(0xFF8FA0B5)],
      coverIcon: Icons.cloud_rounded,
    ),
    BookModel(
      id: 'filosofi-kopi-h',
      title: 'Filosofi Kopi',
      author: 'Dee Lestari',
      category: 'Cerpen',
      rating: 4.8,
      views: 210000,
      totalChapters: 10,
      currentChapter: 3,
      synopsis:
          'Kumpulan cerita pendek tentang pencarian makna hidup lewat secangkir '
          'kopi dan persahabatan.',
      tags: const ['Cerpen'],
      status: 'Ongoing',
      progress: 0.32,
      coverGradient: const [Color(0xFF6F4E37), Color(0xFF3B2A1E)],
      coverIcon: Icons.coffee_rounded,
    ),
  ];

  static final List<BookModel> collectionBooks = [
    BookModel(
      id: 'gadis-pantai-c',
      title: 'Gadis Pantai',
      author: 'Pramoedya Ananta Toer',
      category: 'Novel',
      rating: 4.8,
      views: 178000,
      totalChapters: 28,
      currentChapter: 12,
      synopsis: 'Kisah seorang gadis pantai yang dinikahi bangsawan Jawa.',
      tags: const ['Novel'],
      status: 'Ongoing',
      progress: 0.43,
      coverGradient: const [Color(0xFF2E2B26), Color(0xFF120F0C)],
      coverIcon: Icons.beach_access_rounded,
    ),
    BookModel(
      id: 'hujan-bulan-juni-c',
      title: 'Hujan Bulan Juni',
      author: 'Sapardi Djoko Damono',
      category: 'Puisi',
      rating: 4.9,
      views: 320000,
      totalChapters: 20,
      currentChapter: 20,
      synopsis: 'Kumpulan puisi tentang cinta yang tabah dan bijaksana.',
      tags: const ['Puisi'],
      status: 'Selesai',
      progress: 1.0,
      coverGradient: const [Color(0xFFCED9E6), Color(0xFF8FA0B5)],
      coverIcon: Icons.cloud_rounded,
    ),
    BookModel(
      id: 'kumpulan-cerita-c',
      title: 'Kumpulan Cerita',
      author: 'Andrina Wijaya',
      category: 'Cerpen',
      rating: 4.6,
      views: 65000,
      totalChapters: 8,
      currentChapter: 1,
      synopsis: 'Antologi cerpen kota malam dari berbagai penulis muda.',
      tags: const ['Cerpen'],
      status: 'Ongoing',
      progress: 0.12,
      coverGradient: const [Color(0xFF223447), Color(0xFF0D1620)],
      coverIcon: Icons.location_city_rounded,
    ),
    BookModel(
      id: 'bumi-manusia-c',
      title: 'Bumi Manusia',
      author: 'Pramoedya Ananta Toer',
      category: 'Novel',
      rating: 4.9,
      views: 512000,
      totalChapters: 40,
      currentChapter: 32,
      synopsis: 'Kisah Minke di masa kolonial Belanda.',
      tags: const ['Novel'],
      status: 'Ongoing',
      progress: 0.8,
      coverGradient: const [Color(0xFF3B4E6B), Color(0xFF16233A)],
      coverIcon: Icons.public_rounded,
    ),
  ];

  static final List<BookModel> searchResults = [
    BookModel(
      id: 'senja-di-jakarta-s',
      title: 'Senja di Jakarta',
      author: 'Mochtar Lubis',
      category: 'Novel',
      rating: 4.5,
      views: 88000,
      totalChapters: 18,
      currentChapter: 0,
      synopsis:
          'Potret kehidupan Jakarta tahun 1950-an lewat berbagai kisah yang '
          'saling bersinggungan.',
      tags: const ['Novel'],
      status: 'Selesai',
      progress: 0,
      coverGradient: const [Color(0xFFE0703F), Color(0xFF7A2E14)],
      coverIcon: Icons.wb_twilight_rounded,
    ),
    BookModel(
      id: 'hujan-bulan-juni-s',
      title: 'Hujan Bulan Juni',
      author: 'Sapardi Djoko Damono',
      category: 'Puisi',
      rating: 4.9,
      views: 320000,
      totalChapters: 20,
      currentChapter: 0,
      synopsis: 'Kumpulan puisi tentang cinta yang tabah dan bijaksana.',
      tags: const ['Puisi'],
      status: 'Ongoing',
      progress: 0,
      coverGradient: const [Color(0xFFCED9E6), Color(0xFF8FA0B5)],
      coverIcon: Icons.cloud_rounded,
    ),
    BookModel(
      id: 'filosofi-kopi-s',
      title: 'Filosofi Kopi',
      author: 'Dee Lestari',
      category: 'Cerpen',
      rating: 4.8,
      views: 210000,
      totalChapters: 10,
      currentChapter: 0,
      synopsis: 'Cerita pendek tentang pencarian makna hidup.',
      tags: const ['Cerpen'],
      status: 'Ongoing',
      progress: 0,
      coverGradient: const [Color(0xFF6F4E37), Color(0xFF3B2A1E)],
      coverIcon: Icons.coffee_rounded,
    ),
  ];

  static const List<StatSummary> statSummaries = [
    StatSummary(
      title: 'Total Pembaca',
      value: '667k',
      delta: '+12% dari minggu lalu',
      isPositive: true,
    ),
    StatSummary(
      title: 'Total Ulasan',
      value: '2.7k',
      delta: '+5% dari minggu lalu',
      isPositive: true,
    ),
    StatSummary(
      title: 'Bookmark',
      value: '12.4k',
      delta: 'Stabil',
      isStable: true,
    ),
    StatSummary(
      title: 'Apresiasi/Likes',
      value: '8.9k',
      delta: '+18% dari minggu lalu',
      isPositive: true,
    ),
  ];

  static const List<DailyStatPoint> weeklyTrend = [
    DailyStatPoint(dayLabel: 'Sen', value: 55),
    DailyStatPoint(dayLabel: 'Sel', value: 78),
    DailyStatPoint(dayLabel: 'Rab', value: 60),
    DailyStatPoint(dayLabel: 'Kam', value: 82),
    DailyStatPoint(dayLabel: 'Jum', value: 70),
    DailyStatPoint(dayLabel: 'Sab', value: 118, highlighted: true),
    DailyStatPoint(dayLabel: 'Min', value: 96),
  ];

  static const List<PopularWorkStat> statPopularWorks = [
    PopularWorkStat(
      title: 'Laut Bercerita',
      category: 'Novel',
      views: '245k Pembaca',
      delta: '+5.2k',
      coverGradient: [Color(0xFF1F3A5F), Color(0xFF0B1526)],
    ),
    PopularWorkStat(
      title: 'Senja di Jakarta',
      category: 'Puisi',
      views: '182k Pembaca',
      delta: '+2.1k',
      coverGradient: [Color(0xFFE0703F), Color(0xFF7A2E14)],
    ),
    PopularWorkStat(
      title: 'Kumpulan Cerita Pendek',
      category: 'Cerpen',
      views: '96k Pembaca',
      delta: '+1.4k',
      coverGradient: [Color(0xFF223447), Color(0xFF0D1620)],
    ),
  ];
}
