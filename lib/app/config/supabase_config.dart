class SupabaseConfig {
  static const String supabaseUrl =
      'https://qkkvrmscrmkrpitnhhzb.supabase.co';

  static const String supabaseAnonKey =
      'sb_publishable_xU0EcMThB3HAz6XaAzjaVA_ht9Umy8n';

  static const String usersTable = 'users';
  static const String booksTable = 'books';
  static const String reviewsTable = 'reviews';
  static const String statsTable = 'user_stats';

  /// Riwayat baca per user (halaman Perpustakaan tab Histori).
  static const String readingHistoryTable = 'reading_history';

  /// Koleksi karya per user (halaman Perpustakaan tab Koleksi).
  static const String collectionsTable = 'user_collections';

  /// Umpan balik user (halaman Profil > Bantuan & Umpan Balik).
  static const String feedbackTable = 'feedback';
}