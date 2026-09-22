import 'package:get/get.dart';

import '../data/models/user_model.dart';
import 'supabase_auth_service.dart';

/// Wrapper tipis di atas [SupabaseAuthService].
/// Controller lain (Profil, Login, Register, Detail Buku, Daftar Penulis)
/// tetap memakai AuthService.to seperti sebelumnya, tapi sekarang state
/// yang dibaca/ditulis benar-benar berasal dari Supabase.
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final SupabaseAuthService _supabaseAuth = SupabaseAuthService.to;

  RxBool get isLoggedIn => _supabaseAuth.isLoggedIn;
  Rx<UserModel?> get currentUser => _supabaseAuth.currentUser;
  RxBool get isLoading => _supabaseAuth.isLoading;
  RxString get errorMessage => _supabaseAuth.errorMessage;

  Future<void> login({required String email, required String password}) =>
      _supabaseAuth.login(email: email, password: password);

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) =>
      _supabaseAuth.register(email: email, password: password, name: name);

  Future<void> logout() => _supabaseAuth.logout();

  Future<void> becomeWriter({
    required String penName,
    List<String> favoriteGenres = const [],
  }) =>
      _supabaseAuth.becomeWriter(penName: penName, favoriteGenres: favoriteGenres);
}