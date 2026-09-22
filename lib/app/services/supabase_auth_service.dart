import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_model.dart';
import '../config/supabase_config.dart';

class SupabaseAuthService extends GetxService {
  static SupabaseAuthService get to => Get.find<SupabaseAuthService>();

  final supabase = Supabase.instance.client;

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_checkUserSession());
  }

  // ============================================================
  // CEK SESSION
  // ============================================================

  Future<void> _checkUserSession() async {
    final session = supabase.auth.currentSession;

    if (session != null) {
      // Yang penting session Supabase masih aktif
      isLoggedIn.value = true;

      // Ambil data profil jika tersedia.
      // Gagal mengambil profil tidak akan membuat user logout.
      try {
        await _loadUserData(session.user.id);
      } catch (e) {
        print('Gagal memuat profil saat cek session: $e');
      }
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
        },
      );

      if (response.user != null) {
        // Login dianggap berhasil jika Supabase berhasil membuat akun.
        isLoggedIn.value = true;

        // Coba ambil profil.
        // Kalau gagal, tidak menghalangi masuk aplikasi.
        try {
          await _loadUserData(response.user!.id);
        } catch (e) {
          print('Profil belum berhasil dimuat: $e');
        }
      }
    } catch (e) {
      errorMessage.value = 'Error register: ${e.toString()}';
      print('Register error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // ========================================================
      // LOGIN SUPABASE BERHASIL
      // ========================================================

      if (response.user != null) {
        // LANGSUNG anggap sudah login.
        // Tidak menunggu _loadUserData().
        isLoggedIn.value = true;

        // Coba mengambil data profil.
        // Kalau gagal, user tetap bisa masuk ke halaman utama
        // dan membuka halaman Profil.
        try {
          await _loadUserData(response.user!.id);
        } catch (e) {
          print('Gagal memuat data profil: $e');
        }
      }
    } catch (e) {
      errorMessage.value = 'Error login: ${e.toString()}';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<bool> _loadUserData(String userId) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      // Kalau data user belum ada di tabel users
      if (response == null) {
        print('Data user tidak ditemukan di tabel users.');

        // Jangan membuat login gagal.
        return false;
      }

      currentUser.value = UserModel(
        id: response['id']?.toString() ?? userId,
        email: response['email']?.toString() ?? '',
        name: response['name']?.toString() ?? 'Pengguna',
        badge: response['badge']?.toString() ?? 'Pembaca',
        karyaDibaca: response['karya_dibaca'] ?? 0,
        koleksi: response['koleksi'] ?? 0,
        pengikut: response['followers_count'] ?? 0,
        isWriter: response['is_writer'] ?? false,
        penName: response['pen_name'],
        favoriteGenres:
            List<String>.from(response['favorite_genres'] ?? []),
      );

      return true;
    } catch (e) {
      print('Load user data error: $e');

      // Jangan mengubah isLoggedIn menjadi false.
      return false;
    }
  }

  // ============================================================
  // BECOME WRITER
  // ============================================================

  Future<void> becomeWriter({
    required String penName,
    required List<String> favoriteGenres,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      await supabase
          .from(SupabaseConfig.usersTable)
          .update({
            'is_writer': true,
            'pen_name': penName,
            'favorite_genres': favoriteGenres,
          })
          .eq('id', userId);

      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          isWriter: true,
          penName: penName,
          favoriteGenres: favoriteGenres,
        );
      }
    } catch (e) {
      errorMessage.value =
          'Error jadi penulis: ${e.toString()}';

      print('Become writer error: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      isLoading.value = true;

      await supabase.auth.signOut();

      currentUser.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      errorMessage.value = 'Error logout: ${e.toString()}';

      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}