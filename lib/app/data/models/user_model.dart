/// Model data pengguna / penulis di aplikasi KARYAKU.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String badge;
  final int karyaDibaca;
  final int koleksi;
  final int pengikut;
  final bool isWriter;
  final String penName;
  final List<String> favoriteGenres;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.badge,
    required this.karyaDibaca,
    required this.koleksi,
    required this.pengikut,
    this.isWriter = false,
    this.penName = '',
    this.favoriteGenres = const [],
  });

  UserModel copyWith({
    bool? isWriter,
    String? penName,
    List<String>? favoriteGenres,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name,
        email: email,
        badge: badge,
        karyaDibaca: karyaDibaca,
        koleksi: koleksi,
        pengikut: pengikut,
        isWriter: isWriter ?? this.isWriter,
        penName: penName ?? this.penName,
        favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      );
}