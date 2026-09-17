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
    _checkUserSession();
  }

  // Cek apakah user sudah memiliki sesi aktif
  void _checkUserSession() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _loadUserData(session.user.id);
      isLoggedIn.value = true;
    }
  }

  // Register User Baru
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Buat data profil user baru di tabel users
        await supabase.from(SupabaseConfig.usersTable).insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'badge': 'Anggota Baru',
          'is_writer': false,
          'followers_count': 0,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _loadUserData(response.user!.id);
        isLoggedIn.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Error register: ${e.toString()}';
      print('Register error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Login User
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        isLoggedIn.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Error login: ${e.toString()}';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch profil user dari tabel database
  Future<void> _loadUserData(String userId) async {
    try {
      final response = await supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      currentUser.value = UserModel(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        badge: response['badge'],
        karyaDibaca: response['karya_dibaca'] ?? 0,
        koleksi: response['koleksi'] ?? 0,
        pengikut: response['followers_count'] ?? 0,
        isWriter: response['is_writer'] ?? false,
        penName: response['pen_name'],
        favoriteGenres: List<String>.from(response['favorite_genres'] ?? []),
      );

    } catch (e) {
      print('Load user data error: $e');
    }
  }

  // Upgrade status akun menjadi Penulis
  Future<void> becomeWriter({
    required String penName,
    required List<String> favoriteGenres,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from(SupabaseConfig.usersTable).update({
        'is_writer': true,
        'pen_name': penName,
        'favorite_genres': favoriteGenres,
      }).eq('id', userId);

      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          isWriter: true,
          penName: penName,
          favoriteGenres: favoriteGenres,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error jadi penulis: ${e.toString()}';
      print('Become writer error: $e');
    }
  }

  // Logout
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