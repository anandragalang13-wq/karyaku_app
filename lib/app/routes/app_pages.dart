import 'package:get/get_navigation/src/routes/get_route.dart';

import '../modules/detail_buku/bindings/detail_buku_binding.dart';
import '../modules/detail_buku/views/detail_buku_view.dart';
import '../modules/daftar_penulis/bindings/daftar_penulis_binding.dart';
import '../modules/daftar_penulis/views/daftar_penulis_view.dart';
import '../modules/kelola_karya/bindings/kelola_karya_binding.dart';
import '../modules/kelola_karya/views/kelola_karya_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_nav/bindings/main_nav_binding.dart';
import '../modules/main_nav/views/main_nav_view.dart';
import '../modules/pengaturan_akun/bindings/pengaturan_akun_binding.dart';
import '../modules/pengaturan_akun/views/pengaturan_akun_view.dart';
import '../modules/progres_cerita/bindings/progres_cerita_binding.dart';
import '../modules/progres_cerita/views/progres_cerita_view.dart';
import '../modules/reader/bindings/reader_binding.dart';
import '../modules/reader/views/reader_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tambah_karya/bindings/tambah_karya_binding.dart';
import '../modules/tambah_karya/views/tambah_karya_view.dart';
import '../modules/tulis_bab/bindings/tulis_bab_binding.dart';
import '../modules/tulis_bab/views/tulis_bab_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: Routes.DETAIL_BUKU,
      page: () => const DetailBukuView(),
      binding: DetailBukuBinding(),
    ),
    GetPage(
      name: Routes.PENGATURAN_AKUN,
      page: () => const PengaturanAkunView(),
      binding: PengaturanAkunBinding(),
    ),
    GetPage(
      name: Routes.KELOLA_KARYA,
      page: () => const KelolaKaryaView(),
      binding: KelolaKaryaBinding(),
    ),
    GetPage(
      name: Routes.PROGRES_CERITA,
      page: () => const ProgresCeritaView(),
      binding: ProgresCeritaBinding(),
    ),
    GetPage(
      name: Routes.TULIS_BAB,
      page: () => const TulisBabView(),
      binding: TulisBabBinding(),
    ),
    GetPage(
      name: Routes.READER,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: Routes.TAMBAH_KARYA,
      page: () => const TambahKaryaView(),
      binding: TambahKaryaBinding(),
    ),
    GetPage(
      name: Routes.DAFTAR_PENULIS,
      page: () => const DaftarPenulisView(),
      binding: DaftarPenulisBinding(),
    ),
  ];
}