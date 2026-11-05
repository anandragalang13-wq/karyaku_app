# KARYAKU — Implementasi Flutter (GetX)

Implementasi Flutter dari 9 desain UI KARYAKU (Beranda, Detail Buku, Histori
Baca, Koleksi Saya, Pencarian, Pengaturan Akun, Pengaturan Buku/Reader, Profil,
dan Kelola Karya), disusun dengan pola **GetX** (Controller — View —
Binding + Route Management).

## Struktur Proyek

```
lib/
  main.dart                       # Entry point (GetMaterialApp)
  app/
    routes/
      app_routes.dart             # Nama-nama route
      app_pages.dart              # Daftar GetPage + binding
    theme/
      app_colors.dart             # Palet warna
      app_theme.dart              # ThemeData + enum ReaderTheme/ReaderFont
    data/
      models/                     # BookModel, ReviewModel, UserModel, dst
      mock_data.dart               # Data contoh (pengganti API)
    widgets/                      # Widget reusable (bottom nav, book cover, dst)
    modules/
      main_nav/                   # Shell 4 tab: Histori, Temukan, Beranda, Profil
      beranda/                    # Layar "Beranda"
      detail_buku/                # Layar "Detail Buku"
      histori_koleksi/            # Layar "Histori Baca" + "Koleksi Saya" (tab)
      pencarian/                  # Layar "Pencarian" + bottom sheet Filter & Urutkan
      pengaturan_akun/            # Layar "Pengaturan & Akun"
      reader/                     # Layar baca + bottom sheet "Pengaturan Buku"
      profil/                     # Layar "Profil"
      kelola_karya/               # Layar "Kelola Karya": draft + statistik buku (fl_chart)
      tulis_bab/                  # Layar "Tulis Bab Baru" (lanjutan cerita draft)
      tambah_karya                # Layar 
```

Setiap modul GetX terdiri dari 3 file:
- `*_controller.dart` — state & logic (`GetxController`, reactive `.obs`)
- `*_view.dart` — UI (`GetView<Controller>`)
- `*_binding.dart` — dependency injection (`Get.lazyPut`)

## Navigasi

- 4 tab utama (Histori, Temukan, Beranda, Profil) dikelola oleh
  `MainNavController` dengan `IndexedStack`, sehingga state tiap tab
  tetap terjaga saat berpindah tab.
- Halaman lain (Detail Buku, Pengaturan Akun, Kelola Karya, Tulis Bab, Reader)
  memakai named routes (`Get.toNamed`) dan menerima data lewat `Get.arguments`.

## Cara Menjalankan

Karena proyek ini hanya berisi `lib/` + `pubspec.yaml` (tanpa folder platform
android/ios/web), lakukan salah satu cara berikut:

**Cara 1 — Proyek baru:**
```bash
flutter create karyaku_app
# lalu timpa folder lib/ dan pubspec.yaml dengan isi dari proyek ini
cd karyaku_app
flutter pub get
flutter run
```

**Cara 2 — Tambahkan folder platform ke proyek ini:**
```bash
cd karyaku_app       # folder hasil ekstrak zip ini
flutter create .      # menambahkan android/ios/web tanpa menimpa lib/pubspec
flutter pub get
flutter run
```

## Dependensi

- `get` — state management, dependency injection, dan routing
- `fl_chart` — grafik batang "Pembaca per Karya" di halaman Kelola Karya
- `google_fonts` — font Inter (default UI) dan Merriweather/Noto Serif untuk mode baca

## Catatan

- Sampul buku memakai `BookCover` (gradient + ikon) sebagai pengganti gambar
  jaringan asli, karena tidak ada aset gambar yang disediakan.
- Semua data (buku, ulasan, statistik, dsb.) berasal dari `mock_data.dart`
  sebagai simulasi API/backend — silakan ganti dengan pemanggilan service/
  repository sungguhan sesuai kebutuhan.
- Preferensi tampilan baca (warna background, jenis huruf, ukuran font)
  disimpan di perangkat lewat `ReadingPrefsService` (SharedPreferences) dan
  dipakai bersama oleh halaman **Pengaturan & Akun** serta panel
  **Pengaturan Buku** di Reader, sehingga pilihannya tidak hilang saat
  aplikasi dibuka kembali.
- Halaman **Kelola Karya** (pengganti Statistik) mengambil karya milik penulis
  langsung dari Supabase (`BookService.getMyWorks`) berikut jumlah ulasannya.
  Bab baru yang ditulis lewat layar **Tulis Bab Baru** disimpan sebagai blok
  dalam kolom `books.content` dengan penanda `[[BAB]]`
  (`lib/app/data/chapter_content.dart`), jadi tidak perlu migrasi skema;
  penulis hanya bisa menambah bab selama status karya masih draft/ditolak
  (dibatasi RLS di `supabase/schema.sql`).
