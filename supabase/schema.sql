-- =====================================================================
-- KARYAKU - skema Supabase (SATU SKRIP UTUH)
-- ---------------------------------------------------------------------
-- CARA MENJALANKAN (1x):
--   1. Buka Supabase Dashboard > SQL Editor > New query
--   2. Salin SELURUH isi file ini ke sana
--   3. Klik Run
--
-- Di terminal (PowerShell) untuk menyalin otomatis ke clipboard:
--   Get-Content supabase\schema.sql -Raw | Set-Clipboard
--
-- Catatan:
-- - Aman dijalankan berulang kali (idempotent): tabel/kolom/kebijakan yang
--   sudah ada tidak dihapus, yang kurang saja yang ditambahkan.
-- - Isi file ini: tabel, kolom, RLS, hak akses (grant), bucket Storage,
--   trigger profil otomatis, data awal 6 karya, dan view daftar penulis.
-- - Bila ada tabel aplikasi yang bernama lain (mis. `profiles`), ubah
--   `SupabaseConfig.usersTable` di lib/app/config/supabase_config.dart.
-- =====================================================================

-- ---------- 1. USERS (profil, 1 baris per akun auth) ----------
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade
);
alter table public.users
  add column if not exists email text,
  add column if not exists name text,
  add column if not exists badge text default 'Pembaca',
  add column if not exists karya_dibaca int default 0,
  add column if not exists koleksi int default 0,
  add column if not exists followers_count int default 0,
  add column if not exists is_writer boolean default false,
  add column if not exists pen_name text,
  add column if not exists favorite_genres text[] default '{}',
  add column if not exists created_at timestamptz default now();

-- Buat baris profil otomatis setiap ada akun baru
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.users (id, email, name)
  values (new.id, new.email,
          coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Isi profil untuk akun yang sudah terlanjur terdaftar sebelum trigger ada
insert into public.users (id, email, name)
select id, email, coalesce(raw_user_meta_data->>'name', split_part(email, '@', 1))
from auth.users
on conflict (id) do nothing;

alter table public.users enable row level security;
drop policy if exists "users_select_own" on public.users;
drop policy if exists "users_update_own" on public.users;
drop policy if exists "users_insert_own" on public.users;
create policy "users_select_own" on public.users
  for select to authenticated using (id = auth.uid());
create policy "users_update_own" on public.users
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
-- User boleh membuat baris profilnya sendiri bila belum ada (mis. akun
-- lama yang dibuat sebelum trigger/tabel siap). Tanpa ini pendaftaran
-- sebagai penulis diam-diam gagal sehingga fitur tulis karya tidak muncul.
create policy "users_insert_own" on public.users
  for insert to authenticated with check (id = auth.uid());

-- Klien hanya boleh mengubah kolom profil, bukan badge/pengikut
revoke insert, update, delete on public.users from anon, authenticated;
grant insert (id, email, name, badge, is_writer, pen_name, favorite_genres)
  on public.users to authenticated;
grant update (name, is_writer, pen_name, favorite_genres) on public.users to authenticated;

-- ---------- 2. BOOKS (karya) ----------
create table if not exists public.books (
  id uuid primary key default gen_random_uuid()
);
alter table public.books
  add column if not exists author_id uuid references auth.users(id) on delete set null,
  add column if not exists author text,
  add column if not exists title text,
  add column if not exists category text default 'Novel',      -- Novel | Puisi | Cerpen
  add column if not exists content text default '',
  add column if not exists synopsis text,
  add column if not exists tags text[] default '{}',
  add column if not exists cover_asset text,                   -- path asset ATAU URL gambar
  add column if not exists status text default 'Ongoing',      -- Ongoing | Selesai
  add column if not exists approval_status text default 'draft', -- draft | pending | approved | rejected
  add column if not exists rejection_reason text,
  add column if not exists views_count int default 0,
  add column if not exists rating numeric(2,1) default 0,
  add column if not exists total_chapters int default 1,
  add column if not exists current_chapter int default 0,
  add column if not exists created_at timestamptz default now(),
  add column if not exists submitted_at timestamptz,
  add column if not exists approved_at timestamptz;

create index if not exists books_approval_idx on public.books (approval_status, views_count desc);

alter table public.books enable row level security;
drop policy if exists "books_select" on public.books;
drop policy if exists "books_insert_own" on public.books;
drop policy if exists "books_update_own" on public.books;
-- Publik hanya melihat karya approved; penulis juga melihat karyanya sendiri
create policy "books_select" on public.books
  for select using (approval_status = 'approved' or author_id = auth.uid());
-- Penulis hanya boleh membuat draft/pending (tidak bisa meng-approve sendiri)
create policy "books_insert_own" on public.books
  for insert to authenticated
  with check (author_id = auth.uid() and approval_status in ('draft', 'pending'));
create policy "books_update_own" on public.books
  for update to authenticated
  using (author_id = auth.uid())
  with check (author_id = auth.uid() and approval_status in ('draft', 'pending'));
-- Penulis hanya boleh menghapus karya miliknya sendiri
drop policy if exists "books_delete_own" on public.books;
create policy "books_delete_own" on public.books
  for delete to authenticated
  using (author_id = auth.uid());

revoke insert, update, delete on public.books from anon, authenticated;
grant insert (author_id, author, title, category, content, synopsis, tags, cover_asset,
              status, approval_status, submitted_at, total_chapters, current_chapter)
  on public.books to authenticated;
grant update (title, category, content, synopsis, tags, cover_asset, status,
              approval_status, submitted_at, total_chapters, current_chapter)
  on public.books to authenticated;
grant delete on public.books to authenticated;

-- ---------- 3. REVIEWS (ulasan) ----------
-- book_id sengaja bertipe text agar cocok dengan tipe id tabel books yang
-- sudah ada (uuid maupun text).
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid()
);
alter table public.reviews
  add column if not exists book_id text,
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists user_name text,
  add column if not exists rating int,
  add column if not exists comment text,
  add column if not exists likes_count int default 0,
  add column if not exists created_at timestamptz default now();

create index if not exists reviews_book_idx on public.reviews (book_id, created_at desc);

alter table public.reviews enable row level security;
drop policy if exists "reviews_select" on public.reviews;
drop policy if exists "reviews_insert_own" on public.reviews;
create policy "reviews_select" on public.reviews for select using (true);
create policy "reviews_insert_own" on public.reviews
  for insert to authenticated
  with check (user_id = auth.uid() and rating between 1 and 5);

revoke insert, update, delete on public.reviews from anon, authenticated;
grant insert (book_id, user_id, user_name, rating, comment) on public.reviews to authenticated;

-- ---------- 4. STORAGE: bucket cover buku ----------
insert into storage.buckets (id, name, public)
values ('covers', 'covers', true)
on conflict (id) do nothing;

drop policy if exists "covers_public_read" on storage.objects;
drop policy if exists "covers_upload_own_folder" on storage.objects;
create policy "covers_public_read" on storage.objects
  for select using (bucket_id = 'covers');
create policy "covers_upload_own_folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'covers' and (storage.foldername(name))[1] = auth.uid()::text);

-- ---------- 5. DATA AWAL (6 karya approved, isi bab unik per karya) ----------
-- Setiap karya punya judul, sinopsis, kategori, DAN ISI BAB yang
-- berbeda-beda sesuai data aslinya (bukan teks contoh yang seragam).
-- Isi disimpan dalam format blok `<nomor>|<judul>` dipisah penanda [[BAB]].
-- Aman dijalankan ulang: baris baru disisipkan, sedangkan isi karya lama
-- yang masih berupa ringkasan diperbarui menjadi bab-bab sebenarnya.
with seed (author, title, category, content, synopsis, tags, cover_asset,
           approval_status, views_count, rating, total_chapters,
           created_at, approved_at) as (
  values
  ('Leila S. Chudori', 'Laut Bercerita', 'Novel',
   '1|Kelompok Winatra

Malam itu, Jakarta seperti tidak pernah benar-benar tidur, melainkan hanya bersembunyi di balik gerimis tipis yang turun tanpa henti sejak senja. Bau tanah basah yang menyengat bercampur dengan aroma jelaga bus, sampah menumpuk, dan asap knalpot menyusup masuk melalui celah-celah papan kayu kontrakan. Namun di dalam ruang sempit berukuran empat kali empat meter di belakang kompleks kampus itu, udara terasa jauh lebih sesak. Ruangan tersebut dipenuhi asap rokok kretek murah yang membumbung pekat, berbaur dengan deru diskusi yang membara tanpa tanda-tanda akan mereda.

Biru Laut duduk tersudut di atas kasur lipat tipis yang sudah aus dan kehilangan bentuknya. Ia memangku setumpuk pamflet stencil yang baru saja selesai dicetak secara sembunyi-sembunyi. Tinta stensilan itu belum sepenuhnya kering, meninggalkan noda-noda hitam di ujung jemarinya dan bau kimia yang menyengat hidung. Sambil menyimak perdebatan di depannya, Laut menyeruput kopi hitam dingin dari cangkir kaleng yang sudah berkarat di bagian pinggirnya, membiarkan rasa pahit itu menahan kantuk yang menggelayut di pelupuk matanya.

"Besok pagi tepat pukul tujuh, kita harus sudah menyebar ini di tiga titik utama," kata Kinan sambil mengetukkan jarinya ke atas meja kayu lapuk. Matanya menatap tajam ke arah tumpukan kertas di pangkuan Laut. "Gerbang depan, kantin humaniora, dan lorong perpustakaan. Jangan sampai ada yang tertinggal. Kalau ada petugas kampus atau aparat berpakaian preman yang mencegat dan bertanya, kita konsisten dengan jawaban awal: ini cuma selebaran undangan diskusi sastra dan apresiasi puisi."

Laut tersenyum tipis, sebuah senyuman samar yang hampir tak terlihat dalam remang lampu minyak. Ia menggelengkan kepala pelan. Di dalam hatinya, ia selalu mengagumi keberanian dan kecerdikan kawan-kawannya di Kelompok Winatra. Mereka selalu punya cara untuk menyulap perlawanan menjadi bentuk-bentuk yang elok. Mereka menyelipkan bait-bait sajak perlawanan, alegori, dan kalimat puisi di antara kritik tajam atas ketidakadilan politik yang sedang terjadi. Seolah-olah kata-kata indah yang dipetik dari sastra klasik bisa menjadi perisai tak kasat mata untuk melindungi diri dari intaian intelijen yang bertebaran di setiap sudut kota. Bagi mereka, sastra bukan cuma soal estetika, melainkan peluru yang dibungkus dengan keindahan.

"Kamu yakin mereka bakal percaya kalau ini cuma acara puisi, Nan?" tanya Alex yang bersandar di tembok rapuh dekat pintu. Wajahnya tampak lelah, dengan lingkaran hitam tebal di bawah matanya setelah dua malam tak tidur menjaga mesin cetak tua. "Kemarin Lazuardi bilang, beberapa orang asing berambut papak sudah mulai sering nongkrong di warung kopi depan gang. Mereka ndak pernah beli apa-apa, cuma duduk seharian sambil memperhatikan siapa saja yang keluar-masuk rumah ini."

"Mau percaya atau tidak, itu masalah mereka," balas Kinan cepat, suaranya mengandung ketegasan yang tak membukakan ruang untuk bantahan. "Tugas kita adalah memastikan gagasan ini sampai ke tangan mahasiswa lain. Kita ndak boleh menyerah sama ketakutan yang sengaja mereka ciptakan."

Namun, kehangatan perdebatan malam itu tak bertahan lama. Tiba-tiba saja, gelisah yang mendalam datang merayap. Suara deru mesin sepeda motor bertransmisi besar yang amat khas terdengar mendekat, lalu berhenti tepat di mulut gang sempit depan kontrakan—berhenti lebih lama dari yang seharusnya. Langkah kaki sepatu bot yang berat menginjak genangan air hujan mulai terdengar melangkah pelan tapi pasti, menuju ke arah pintu mereka.

Seketika itu juga, seluruh dialog terhenti. Hening yang dingin dan mencekam langsung menyergap ruangan. Tak ada satu pun dari mereka yang berani bernapas keras. Anjar, yang mendapat tugas mengawasi area luar di balik selah tirai lusuh dekat jendela, memberi isyarat tangan darurat. Tanpa mengeluarkan suara, ia langsung mematikan lampu minyak.

Ruangan seketika tenggelam dalam kegelapan gulita. Hanya pendar remang dari lampu jalanan jauh di luar yang menyusup tipis melalui celah jendela, memantulkan bayangan-bayangan tubuh mereka yang mematung.

"Laut," bisik Kinan seraya merayap pelan di atas lantai kayu yang berderit. Jemarinya yang dingin dan gemetar langsung menggenggam pergelangan tangan Laut amat erat, menyalurkan getaran ketakutan luar biasa yang coba ia tahan mati-matian. "Kalau malam ini hal terburuk benar-benar terjadi... kalau mereka mendobrak pintu ini dan membawa kita... ingat satu hal."

Kinan mendekatkan wajahnya, bisikannya hampir tenggelam oleh suara detak jantung Laut sendiri. "Jangan pernah sebut nama siapa pun. Jangan pernah akui siapa yang menulis risalah ini. Tutup mulutmu rapat-rapat, apa pun yang mereka lakukan."

Laut mengangguk pelan dalam kegelapan, meski dadanya bergemuruh hebat dan jantungnya berdegup begitu keras hingga terasa berdenyut di sepanjang tenggorokannya. Napasnya tertahan saat mendengar langkah kaki di luar kini berhenti tepat di depan pintu papan kontrakan mereka. Seseorang di luar sana tampak sedang mengamati situasi.

Dalam keheningan mencekam yang rasanya membekukan waktu itu, pikiran Laut melayang jauh melintasi sempitnya kamar tersebut. Ia menatap lurus menembus kegelapan ke arah jendela luar—membayangkan hamparan laut luas yang tak pernah benar-benar bisa ia lihat dari tengah rimba beton kota ini. Laut yang selalu hadir dalam mimpinya: begitu luas, gelap, tenang, namun memeluk erat seluruh rahasia pergerakan dan perjuangan mereka. Sebuah tempat yang terasa seperti satu-satunya muara yang siap menampung segala cerita perjuangan mereka, jika kelak ia dan kawan-kawannya masih diberi kesempatan untuk bernapas, pulang, dan menceritakannya kembali.

[[BAB]]

2|Asmara Jati

Pukul empat dini hari, gerimis belum juga berhenti. Laut membuka pintu kontrakan perlahan dan membiarkan dirinya berdiri sejenak di ambang, menikmati udara dingin yang menghantam wajahnya seperti pertanyaan yang tak punya jawaban. Di saku jaketnya, amplop cokelat berisi tiga puluh ribu rupiah hasil menjahit seragam anak sekolah tetangga sudah ia lipat dua.

Di ujung gang, sepeda motor tua milik pak pos sudah menunggu. Laut tidak naik motor itu. Ia berjalan kaki sejauh dua kilometer ke halte busway, lalu menumpang dua bus menuju kawasan Menteng, tempat adiknya bersekolah di sebuah SMA favorit negeri.

Asmara Jati berdiri di gerbang sekolah dengan tas ransel yang terlalu besar untuk tubuh mungilnya. Rambutnya digelung asal di sisi kiri, seragamnya digulung sedikit di pergelangan tangan karena kebesaran. Ketika melihat Laut, matanya berbinar sebentar—lalu segera berubah ragu.

"Kak, Ibu tanya-tanya semalam," kata Asmara pelan, menunduk sambil menarik-narik tali ranselnya. "Kenapa Kakak pulang tiap subuh. Aku bilang Kakak bantu menjahit di luar. Ibu diam saja, terus menyiapkan nasi untuk Kakak yang sudah dingin."

Laut menahan napas. Ia ingin berkata segalanya: bahwa malam-malamnya habis untuk mengetik risalah, bahwa tangan kakaknya kotor bukan karena jarum dan benang, bahwa di kota ini orang-orang muda dibungkam dengan cara yang lebih halus daripada kekerasan. Namun ia hanya mengusap kepala adiknya dan berkata, "Nanti Kakak pulang lebih awal. Janji."

"Boleh aku ikut, suatu saat?" tanya Asmara, menatap lurus ke mata kakaknya untuk pertama kalinya.

Laut tersenyum, sayat kecil di tengah keresahan. "Kalau nanti sudah aman, Kakak ajak."

Sepanjang jalan kembali ke kontrakan, ia memikirkan janji itu. Janji yang ia tahu bisa saja tak sempat ditepati. Di kota tempat orang menghilang tanpa suara, setiap janji terasa seperti utang yang dibayar di muka.

Sampai di kamar, Kinan sudah duduk di lantai dengan dua cangkir kopi panas. "Ada kabar dari redaksi mahasiswa di sebelah," kata Kinan tanpa basa-basi. "Mereka mau menerbitkan puisi kita, tapi minta nama dicetak samar. Terlalu takut, mungkin."

"Biar saja," jawab Laut. "YANG penting terbaca."

Kinan mengangguk, lalu menyerahkan selembar kertas garis yang dilipat empat. "Ini dari Alex. Daftar orang yang harus dihubungi kalau kita tidak ada di kampus tiga hari berturut-turut. Simpan di tempat yang tidak akan terbuka oleh siapa pun selain kamu."

Laut menerima kertas itu, membacanya sekali, lalu meremasnya menjadi gulungan kecil. Ia memasukkannya ke dalam kaleng kopi bekas yang sudah dikosongkan, menutup rapat-rapat, dan menyimpannya di balik balok jendela yang sudah lapuk. Di luar, gerimis berubah menjadi hujan yang lebih keras, seolah langit sedang menulis ulang seluruh surat yang tak sempat dikirim.

[[BAB]]

3|Perpustakaan Kota

Perpustakaan Kota bukan tempat favorit siapa pun pada tahun itu. Gedungnya tua, langit-langitnya tinggi dan lembap, serta lampu-lampunya berdenyut seperti jantung yang kelelahan. Namun bagi Laut, tempat itu adalah satu-satunya ruang di Jakarta yang masih menganggap kata-kata sebagai hal yang serius.

Selama tiga minggu berturut-turut, ia duduk di meja pojok dekat jendela menghadap halaman belakang, membaca arsip koran lama yang disusun dalam rol mikrofilm. Ia mencari tanggal, nama, dan angka—bukti kecil yang bisa disusun seperti teka-teki sampai gambarnya utuh. Di sela-sela itu, ia menulis. Tangan kirinya memegang buku catatan, tangan kanannya menyalin kutipan puisi, dan sesekali ia menggambar garis di margin sebagai kode bahwa paragraf ini harus dikirim ke redaksi.

"Tuan, kami tutup pukul lima."

Pustakawan tua itu hampir tidak pernah menyapa dengan selain kalimat itu. Namun malam itu, ia berhenti di meja Laut, menatap tumpukan kertas di depannya, lalu berkata dengan suara rendah, "Kalau ada yang mencari, bilang saja kamu sedang menyelesaikan skripsi."

Laut terkejut. Ia hanya sempat mengangguk singkat. Si pustakawan sudah berjalan menjauh, kakinya mengetuk lantai kayu dengan irama yang berubah—lebih cepat dari biasanya.

Malam itu pula Laut mengerti bahwa perlawanan tidak selalu berteriak. Kadang ia bersembunyi di balik sikap diam seorang penjaga pintu, di balik lagu yang dinyanyikan terlalu pelan untuk didengar orang lain, di balik selembar kartu perpustakaan yang diulurkan tanpa banyak pertanyaan.

Di halaman belakang, hujan mulai turun lagi. Laut menutup mikrofilm, memasukkan catatannya ke dalam jaket, dan berjalan ke arah pintu samping yang tidak pernah dikunci. Di sana, Alex sudah menunggu dengan sepeda motor bututnya.

"Kamu telat sepuluh menit," kata Alex.

"Aku menemukan sesuatu," balas Laut, menaiki jok belakang. "Bukan nama. Tapi urutan tanggal. Dan urutan itu cocok dengan jadwal rapat yang seharusnya sudah dibubarkan setahun lalu."

Sepeda motor itu meluncur menembus genangan. Di belakang mereka, lampu perpustakaan dimatikan satu per satu, seperti mata yang akhirnya memilih untuk tidak melihat.

[[BAB]]

4|Surat yang Tak Sampai

Ada satu surat yang tidak pernah Laut kirimkan.

Surat itu ditulis di malam ketika ia sudah tiga hari tidak pulang, ketika badannya panas dan tangannya gemetar, ketika tinta pena membatuk noda di kertas seolah kertas itu juga ikut sakit. Laut menulisnya untuk ibunya, untuk Asmara, dan untuk seseorang yang namanya berulang-ulang di kepalanya namun tak pernah ia sebut di depan kawan-kawannya.

Ibu, begini keadaan kami. Kami tidak sedang bermain-main, dan kami tidak sedang mencari kematian. Kami hanya tidak tahan melihat orang miskin dianggap sebagai kesalahan mereka sendiri. Kalau besok Kakak pulang lebih malam dari biasanya, tolong biarkan lampu dapur menyala.

Ia melipat surat itu, memasukkannya ke dalam amplop, lalu menaruhnya di antara halaman terakhir buku kumpulan puisi yang selalu ia bawa. Esok paginya, buku itu hilang dari atas meja. Laut mencarinya selama dua jam, lalu berhenti, karena ada hal yang lebih penting: seluruh isi kontrakan sudah diobrak-abrik, kasur lipat terbalik, tumpukan pamflet berhamburan basah di lantai, dan kaleng berisi gulungan kertas itu raip.

Yang tersisa hanya sepatu Alex yang tergeletak di tengah ruangan, masih basah oleh hujan semalam.

Laut tidak menangis. Ia hanya duduk di antara puing-puing kecil itu, memunguti satu per satu kertas yang masih terbaca, dan menyusunnya kembali dengan tangan yang pelan sekali, seolah takut kertas itu akan robek lagi kalau terlalu cepat.

Malam harinya, Kinan datang membawa kabar bahwa Alex diperiksa di kantor polisi selama sebelas jam, dan dilepas tanpa surat penahanan. "Mereka tidak menemukan apa-apa," kata Kinan. "Karena tidak ada yang kami simpan di tempat itu sekarang."

Laut mengangguk. Ia tidak bilang bahwa surat untuk ibunya ikut hilang bersama buku itu. Ia tidak bilang bahwa beberapa hal memang lebih baik tidak sampai—karena surat yang tidak sampai kadang melindungi orang yang menerimanya dari kenyataan yang terlalu berat untuk dipegang.

Di beranda kontrakan, hujan turun dengan tenang. Laut berdiri di sana cukup lama, menatap langit yang tidak menjawab apa-apa.

[[BAB]]

5|Kursi Kosong

Dua dekade kemudian, Asmara Jati masih menyiapkan satu porsi nasi tambahan setiap malam Minggu.

Meja makan di rumah kontrakan yang sama kini sudah diperbaiki dua kali, kursinya sudah diganti tiga kali, namun satu kursi di pojok dekat jendela tidak pernah dipindahkan. Catnya mengelupas di sudut kiri atas—bekas jemari seorang kakak yang suka mengetuk meja ketika berpikir.

Asmara tidak pernah bertanya kepada ibunya mengapa porsi itu selalu ada. Ia hanya memastikan sendoknya bersih, menutup piringnya, dan berkata pelan sebelum kembali ke kamar, "Nanti juga dimakan, Ma."

Ia tahu porsi itu tidak akan pernah dimakan. Ia juga tahu bahwa menghapus kebiasaan itu berarti menghapus satu-satunya cara keluarga ini untuk tetap berbicara tentang orang yang hilang tanpa harus menyebutnya.

Malam Minggu itu, lampu meja makan menyala jam sembilan seperti biasa. Asmara membuka pintu untuk tamu yang tak diundang: seorang perempuan tua bertopi anyaman yang menenteng map berisi fotokopi. "Saya dari arsip," kata perempuan itu. "Kami sedang menyusun daftar. Nama adikmu ada di sini, kalau Anda berkenan memeriksanya."

Asmara menerima map itu dengan dua tangan. Di dalamnya: tanggal, tempat, dan satu kalimat pendek yang tidak menjelaskan apa pun tentang bagaimana keadaan kakaknya sekarang, hanya tentang bagaimana keadaan kota ketika kakaknya pergi.

Ia membaca kalimat itu berulang-ulang sampai matanya lelah, lalu meletakkannya di kursi kosong itu—persis di tempat selembar kertas biasanya ditinggalkan oleh seorang kakak yang selalu pulang membawa berita dunia.

Di dapur, ibunya mematikan kompor. Untuk pertama kalinya sejak dua puluh tahun, porsi nasi itu tidak dihangatkan. Ia duduk di kursi sebelahnya dan berkata, "Sudah waktunya kita makan berdua, Ndra."

Asmara mengangguk. Ia mengambil piringnya, lalu piring di kursi kosong itu ikut ia ambil—karena suatu hari nanti, katanya dalam hati, kursi itu harus kembali terisi.

Di luar, hujan bulan juni turun lagi, rahasia seperti biasa, dan tidak seorang pun menahannya.',
   'Kisah persahabatan dan perjuangan yang menyayat hati, dituturkan lewat sudut pandang seorang aktivis mahasiswa.',
   array['Novel','Romansa','Sejarah'], 'assets/images/Laut_Bercerita.png',
   'approved', 245000, 4.9, 5, timestamptz '2026-01-10', timestamptz '2026-01-12'),
  ('Pramoedya Ananta Toer', 'Bumi Manusia', 'Novel',
   '1|HBS Batavia

Minke menatap papan nama sekolah itu seperti menatap gerbang ke dunia lain. Di HBS, murid pribumi dan murid Belanda duduk di ruangan yang sama, tetapi jarak di antara mereka jauh lebih lebar daripada panjang kelas. Ia memilih bangku paling belakang, menggenggam pena sekuat orang menggenggam senjata, lalu mulai menulis tentang cinta, hukum, dan dirinya yang tidak pernah cukup menjadi siapa pun.

[[BAB]]

2|Annelies

Perkenalan dengan Annelies datang seperti hujan pertama di musim panas: tiba-tiba dan menyentuh segalanya. Di bawah payung yang mereka anggap terlalu kecil, Minke belajar bahwa cinta di masa kolonial selalu membawa bayang-bayang keluarga, adat, dan pagar tinggi yang bukan milik mereka berdua.',
   'Novel klasik tentang identitas, cinta, dan perlawanan terhadap penjajahan.',
   array['Novel','Sejarah','Klasik'], 'assets/images/Bumi_Manusia.png',
   'approved', 512000, 4.9, 2, timestamptz '2026-01-05', timestamptz '2026-01-07'),
  ('Sapardi Djoko Damono', 'Aku Ingin', 'Puisi',
   '1|Aku Ingin

Aku ingin mencintaimu dengan sederhana,
tanpa janji yang tingginya melebihi awan,
tanpa pertanyaan yang berputar di kepala setiap malam.

Cukup sepiring nasi pagi,
satu kursi yang selalu menunggu,
dan percakapan kecil tentang hujan yang baru berhenti.

Aku ingin mencintaimu dengan sederhana,
seperti hujan mengenal tanah,
seperti malam mengenal gelap, tanpa perlu disebut namanya.',
   'Puisi cinta yang sederhana namun mendalam.',
   array['Puisi','Romansa'], 'assets/images/Aku_Ingin.png',
   'approved', 98000, 4.8, 1, timestamptz '2026-02-01', timestamptz '2026-02-02'),
  ('Dee Lestari', 'Filosofi Kopi', 'Cerpen',
   '1|Ben dan Jody

Ben mengukur kopi dengan timbangan kecil, seolah menimbang keputusan hidup yang harus presisi. Baginya kopi bukan soal rasa semata, melainkan soal keteguhan: biji yang melewati sangrai gelap tetap manis bila tahu kapan harus berhenti.

Jody adalah api yang selalu menyala di dapur kedai. Ia percaya secangkir kopi terbaik di dunia tidak akan pernah selesai dibuat, selalu ada yang bisa diperbaiki: suhu, gilingan, dan cara kita menunggu. Setiap sore, ketika langit kota mulai oranye, mereka membuka pintu dan membiarkan aroma itu menjadi undangan bagi siapa pun yang lelah.',
   'Cerpen tentang persahabatan, ambisi, dan makna kesempurnaan.',
   array['Cerpen','Persahabatan'], 'assets/images/Filosofi_Kopi.png',
   'approved', 76000, 4.7, 1, timestamptz '2026-02-15', timestamptz '2026-02-16'),
  ('Henry Manampiring', 'Filosofi Teras', 'Novel',
   '1|Berhenti Mengeluh

Malam itu Henry duduk di teras belakang dan menghitung berapa kali ia mengeluh hari ini. Angkanya menyusahkan. Ia lalu menulis satu kalimat di buku catatan: yang bisa saya ubah hanyalah reaksi saya, bukan hujan yang jatuh di luar sana.

[[BAB]]

2|Suara yang Tak Perlu Dijawab

Di era ketika setiap notifikasi menuntut jawaban, teras menjadi tempat ia berlatih diam. Ia membaca para filsuf Stoa, menahan diri dari membalas dengan segera, dan menemukan ketenangan yang tidak dimulai dari perubahan dunia, melainkan dari jeda sepersekian detik sebelum menjawab.',
   'Penerapan filosofi Stoa ala teras rumah untuk menjalani hidup yang lebih tenang.',
   array['Novel','Filosofi'], 'assets/images/Filosofi_Teras.png',
   'approved', 187000, 4.8, 2, timestamptz '2026-01-20', timestamptz '2026-01-22'),
  ('Sapardi Djoko Damono', 'Hujan Bulan Juni', 'Puisi',
   '1|Hujan Bulan Juni

Hujan bulan Juni tidak pernah jatuh diam-diam;
ia membawa nama orang yang kita rindui dan mengetuk atap rumah
seolah ingin dikenali.

Aku duduk dekat jendela,
membiarkan kerinduan itu turun bersama air,
tanpa perlu aku sebut, biar hujan yang menyampaikan.

Kerinduan tidak perlu dipamerkan;
cukup tahu bahwa ada yang menunggu di ujung perjalanan.',
   'Hujan Bulan Juni menceritakan rasa cinta dan kerinduan yang teramat dalam namun disampaikan dengan penuh ketabahan, kebijaksanaan, serta kearifan.',
   array['Puisi','Romansa'], 'assets/images/Hujan_Bulan_Juni.png',
   'approved', 76000, 4.7, 1, timestamptz '2026-02-15', timestamptz '2026-02-16')
),
inserted as (
  insert into public.books (author, title, category, content, synopsis, tags,
                            cover_asset, approval_status, views_count, rating,
                            total_chapters, created_at, approved_at)
  select s.author, s.title, s.category, s.content, s.synopsis, s.tags,
         s.cover_asset, s.approval_status, s.views_count, s.rating,
         s.total_chapters, s.created_at, s.approved_at
  from seed s
  where not exists (select 1 from public.books b where b.title = s.title)
  returning id
),
updated as (
  -- Seed lama yang isinya masih ringkasan (tanpa blok bab) ikut
  -- diperbarui supaya halaman Reader menampilkan isi bab sebenarnya.
  update public.books b
  set content = s.content,
      synopsis = s.synopsis,
      total_chapters = s.total_chapters
  from seed s
  where b.title = s.title
    and b.author = s.author
    and b.content is distinct from s.content
  returning b.id
)
select (select count(*) from inserted) as inserted,
       (select count(*) from updated) as updated;

-- ---------- 6. READING_HISTORY (riwayat baca per user) ----------
-- Halaman Perpustakaan hanya menampilkan karya yang pernah dibuka/dibaca
-- oleh user tersebut; user yang belum membaca apa pun melihat halaman kosong.
create table if not exists public.reading_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id text not null,
  last_chapter int not null default 1,
  progress numeric(4,3) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, book_id)
);

create index if not exists reading_history_user_idx
  on public.reading_history (user_id, updated_at desc);

alter table public.reading_history enable row level security;
drop policy if exists "reading_history_select_own" on public.reading_history;
drop policy if exists "reading_history_insert_own" on public.reading_history;
drop policy if exists "reading_history_update_own" on public.reading_history;
-- Hanya user sendiri yang boleh membaca/menulis riwayat bacanya
create policy "reading_history_select_own" on public.reading_history
  for select to authenticated using (user_id = auth.uid());
create policy "reading_history_insert_own" on public.reading_history
  for insert to authenticated with check (user_id = auth.uid());
create policy "reading_history_update_own" on public.reading_history
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

revoke all on public.reading_history from anon;
revoke insert, update, delete on public.reading_history from authenticated;
grant select on public.reading_history to authenticated;
grant insert (user_id, book_id, last_chapter, progress, updated_at)
  on public.reading_history to authenticated;
grant update (last_chapter, progress, updated_at)
  on public.reading_history to authenticated;

-- ---------- 7. USER_COLLECTIONS (koleksi karya per user) ----------
create table if not exists public.user_collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, book_id)
);

create index if not exists user_collections_user_idx
  on public.user_collections (user_id, created_at desc);

alter table public.user_collections enable row level security;
drop policy if exists "user_collections_select_own" on public.user_collections;
drop policy if exists "user_collections_insert_own" on public.user_collections;
drop policy if exists "user_collections_delete_own" on public.user_collections;
create policy "user_collections_select_own" on public.user_collections
  for select to authenticated using (user_id = auth.uid());
create policy "user_collections_insert_own" on public.user_collections
  for insert to authenticated with check (user_id = auth.uid());
create policy "user_collections_delete_own" on public.user_collections
  for delete to authenticated using (user_id = auth.uid());

revoke all on public.user_collections from anon;
revoke insert, update, delete on public.user_collections from authenticated;
grant select on public.user_collections to authenticated;
grant insert (user_id, book_id) on public.user_collections to authenticated;
grant delete on public.user_collections to authenticated;

-- ---------- 8. FEEDBACK (umpan balik user) ----------
-- Umpan balik yang dikirim dari halaman Profil > Bantuan & Umpan Balik.
-- Datanya benar-benar disimpan di database, bukan data dummy di aplikasi.
create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null default 'Lainnya',   -- Bug | Fitur | Konten | Lainnya
  message text not null,
  email text,
  status text not null default 'baru',        -- baru | diproses | selesai
  created_at timestamptz not null default now()
);

create index if not exists feedback_user_idx
  on public.feedback (user_id, created_at desc);

alter table public.feedback enable row level security;
drop policy if exists "feedback_select_own" on public.feedback;
drop policy if exists "feedback_insert_own" on public.feedback;
-- User hanya boleh membaca & mengirim umpan balik miliknya sendiri
create policy "feedback_select_own" on public.feedback
  for select to authenticated using (user_id = auth.uid());
create policy "feedback_insert_own" on public.feedback
  for insert to authenticated with check (user_id = auth.uid());

revoke all on public.feedback from anon;
revoke insert, update, delete on public.feedback from authenticated;
grant select on public.feedback to authenticated;
grant insert (user_id, category, message, email) on public.feedback to authenticated;

-- ---------- 9. DAFTAR PENULIS (tampilan) ----------
-- CATATAN PENTING: di KARYAKU tidak ada tabel "penulis" terpisah.
-- Data penulis disimpan di tabel `users` (kolom `is_writer`, `pen_name`,
-- `favorite_genres`), sedangkan karya-nya ada di tabel `books`
-- (`author_id`, `author`).
--
-- Supaya daftar penulis mudah dilihat di dashboard Supabase, tabel di bawah
-- adalah TAMPILAN (view) yang mengumpulkan semua akun berstatus penulis.
-- Tampilan ini bersifat opsional: bila gagal dibuat, skrip tetap jalan.
drop view if exists public.authors;
do $$
begin
  if current_setting('server_version_num')::int >= 150000 then
    execute 'create or replace view public.authors with (security_invoker = true) as
      select u.id,
             u.pen_name,
             u.name as display_name,
             u.favorite_genres,
             u.created_at,
             (select count(*) from public.books b where b.author_id = u.id) as works_count
        from public.users u
       where u.is_writer = true';
  else
    execute 'create or replace view public.authors as
      select u.id,
             u.pen_name,
             u.name as display_name,
             u.favorite_genres,
             u.created_at,
             (select count(*) from public.books b where b.author_id = u.id) as works_count
        from public.users u
       where u.is_writer = true';
  end if;
exception when others then
  raise notice 'View public.authors tidak bisa dibuat: %', sqlerrm;
end $$;

-- ---------- 10. LAPORAN HASIL (aman dijalankan di akhir) ----------
-- Ringkasan tabel yang dipakai aplikasi KARYAKU:
select t.name as tabel,
       case when exists (
         select 1 from information_schema.tables x
          where x.table_schema = 'public' and x.table_name = t.name
       ) then 'ada' else 'HILANG' end as status
  from (values ('users'), ('books'), ('reviews'), ('reading_history'),
               ('user_collections'), ('feedback'), ('authors')) as t(name);

-- Ringkasan kolom tabel `users` (harus berisi is_writer & pen_name):
select column_name, data_type
  from information_schema.columns
 where table_schema = 'public' and table_name = 'users'
 order by ordinal_position;

-- Daftar penulis yang sudah terdaftar (kalau tabel `users` terisi):
-- select pen_name, display_name, favorite_genres, works_count from public.authors;

