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

  /// `true` bila profil user berhasil diambil/tersimpan di tabel `users`.
  /// Bila `false`, berarti tabel `users` belum ada atau baris profilnya
  /// belum pernah dibuat — aplikasi tetap jalan (data diambil dari sesi
  /// login), tapi fitur yang butuh tabel `users` belum aktif.
  final RxBool profileSynced = false.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_checkUserSession());
  }

  /// Sinkronkan state login dengan sesi Supabase (dipanggil setelah register).
  Future<void> refreshSession() => _checkUserSession();

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

  /// Memuat profil user dari tabel `users`.
  ///
  /// Aplikasi TIDAK bergantung pada tabel `users` bisa jadi tidak ada:
  /// bila tabel/baris profil tidak tersedia, profil disusun dari sesi
  /// login + metadata akun (`auth.users.user_metadata`) sehingga aplikasi
  /// tetap bisa dipakai (termasuk menulis karya).
  Future<bool> _loadUserData(String userId) async {
    Map<String, dynamic>? row;

    try {
      row = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      print('Read user profile error: $e');
    }

    // Baris profil belum ada → coba buat (butuh tabel `users` + RLS).
    if (row == null) {
      print('Data user tidak ditemukan di tabel users, membuat profil...');

      final authUser = supabase.auth.currentUser;
      final email = authUser?.email ?? '';
      final name = (authUser?.userMetadata?['name'] ??
              email.split('@').first) as String;

      try {
        await supabase.from(SupabaseConfig.usersTable).insert({
          'id': userId,
          'email': email,
          'name': name.isEmpty ? 'Pengguna' : name,
        });

        row = await supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('id', userId)
            .maybeSingle();
      } catch (e) {
        print('Create user profile error: $e');
      }
    }

    // Sumber cadangan: sesi login + metadata akun.
    profileSynced.value = row != null;
    final authUser = supabase.auth.currentUser;
    final meta = authUser?.userMetadata;
    final metaIsWriter = meta?['is_writer'] == true;
    final rowPenName = row?['pen_name']?.toString() ?? '';
    final metaPenName = meta?['pen_name']?.toString() ?? '';
    final rowGenres = row?['favorite_genres'];
    final metaGenres = meta?['favorite_genres'];
    final fallbackName = (meta?['name'] as String?) ??
        (authUser?.email ?? 'Pengguna').split('@').first;

    currentUser.value = UserModel(
      id: row?['id']?.toString() ?? userId,
      email: row?['email']?.toString() ?? authUser?.email ?? '',
      name: row?['name']?.toString() ?? fallbackName,
      badge: row?['badge']?.toString() ?? 'Pembaca',
      karyaDibaca: (row?['karya_dibaca'] as num?)?.toInt() ?? 0,
      koleksi: (row?['koleksi'] as num?)?.toInt() ?? 0,
      pengikut: (row?['followers_count'] as num?)?.toInt() ?? 0,
      isWriter: (row?['is_writer'] ?? false) == true || metaIsWriter,
      penName: rowPenName.isNotEmpty ? rowPenName : metaPenName,
      favoriteGenres: List<String>.from(
        rowGenres is List
            ? rowGenres
            : (metaGenres is List ? metaGenres : const <dynamic>[]),
      ),
    );

    return true;
  }

  // ============================================================
  // BECOME WRITER
  // ============================================================

  /// Mendaftarkan user sebagai penulis.
  ///
  /// Penyimpanan dilakukan berjenjang agar pendaftaran tetap berhasil
  /// walau salah satu cara tidak tersedia:
  /// 1. `UPDATE` baris profil di tabel `users`.
  /// 2. `INSERT` baris profil (bila belum pernah ada).
  /// 3. Cadangan: metadata akun (`auth.users.user_metadata`).
  ///
  /// Mengembalikan `true` bila minimal salah satu cara berhasil.
  Future<bool> becomeWriter({
    required String penName,
    required List<String> favoriteGenres,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      errorMessage.value = 'Sesi login tidak ditemukan. Silakan masuk ulang.';
      return false;
    }

    var stored = false;
    String? lastError;

    // Baca baris profil lebih dulu: supaya kita hanya menulis kolom yang
    // benar-benar ada di database (mis. versi schema lama belum punya
    // kolom `favorite_genres`/`pen_name` → update akan error).
    Map<String, dynamic>? row;
    try {
      row = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      lastError = e.toString();
      print('Read writer profile error: $e');
    }

    bool hasColumn(String column) => row == null || row.containsKey(column);

    final payload = <String, dynamic>{};
    if (hasColumn('is_writer')) payload['is_writer'] = true;
    if (hasColumn('pen_name')) payload['pen_name'] = penName;
    if (hasColumn('favorite_genres')) {
      payload['favorite_genres'] = favoriteGenres;
    }

    // 1) Perbarui baris profil yang sudah ada.
    if (payload.isNotEmpty) {
      try {
        final updated = await supabase
            .from(SupabaseConfig.usersTable)
            .update(payload)
            .eq('id', userId);
        stored = updated.isNotEmpty;
      } catch (e) {
        lastError = e.toString();
        print('Update writer profile error: $e');
      }
    }

    // 2) Baris profil belum ada → buat baru.
    if (!stored && row == null) {
      final authUser = supabase.auth.currentUser;
      final email = authUser?.email ?? '';
      final name = (authUser?.userMetadata?['name'] ??
              email.split('@').first) as String;

      try {
        await supabase.from(SupabaseConfig.usersTable).insert({
          'id': userId,
          'email': email,
          'name': name.isEmpty ? 'Pengguna' : name,
          ...payload,
        });
        stored = true;
      } catch (e) {
        lastError = e.toString();
        print('Insert writer profile error: $e');
      }
    }

    // 3) Status penulis juga dicatat di metadata akun — ini yang dipakai
    //    sebagai cadangan bila kolom `is_writer` belum ada di tabel
    //    `users` (mis. schema lama belum pernah dijalankan ulang).
    var metadataStored = false;
    try {
      await supabase.auth.updateUser(UserAttributes(data: {
        'is_writer': true,
        'pen_name': penName,
      }));
      metadataStored = true;
    } catch (e) {
      lastError = e.toString();
      print('Update auth metadata error: $e');
    }
    stored = stored || metadataStored;

    if (!stored) {
      errorMessage.value =
          'Gagal menyimpan pendaftaran penulis. ${lastError ?? ''}'.trim();
      return false;
    }

    errorMessage.value = '';
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(
        isWriter: true,
        penName: penName,
        favoriteGenres: favoriteGenres,
      );
    }
    return true;
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