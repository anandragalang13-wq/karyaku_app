import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Menyimpan umpan balik pengguna ke tabel `feedback` di Supabase.
///
/// Data yang disimpan benar-benar masuk ke database (bukan data dummy),
/// sehingga bisa dibaca ulang oleh admin/panel pengelola.
class FeedbackService extends GetxService {
  static FeedbackService get to => Get.find<FeedbackService>();

  final SupabaseClient supabase = Supabase.instance.client;

  /// Mengirim umpan balik milik user yang sedang login.
  ///
  /// Mengembalikan `true` bila data berhasil disimpan, `false` bila user
  /// belum login atau terjadi error di server.
  Future<bool> submit({
    required String category,
    required String message,
    String? email,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;

    try {
      await supabase.from(SupabaseConfig.feedbackTable).insert({
        'user_id': userId,
        'category': category,
        'message': trimmed,
        'email': (email == null || email.trim().isEmpty) ? null : email.trim(),
      });
      return true;
    } catch (e) {
      print('Submit feedback error: $e');
      return false;
    }
  }

  /// Umpan balik yang pernah dikirim user sendiri (terbaru dulu).
  Future<List<Map<String, dynamic>>> myFeedback() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final rows = await supabase
          .from(SupabaseConfig.feedbackTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return [
        for (final row in rows as List) Map<String, dynamic>.from(row as Map),
      ];
    } catch (e) {
      print('Get my feedback error: $e');
      return [];
    }
  }
}
