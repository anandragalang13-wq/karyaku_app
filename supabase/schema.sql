-- =====================================================================
-- KARYAKU - skema Supabase
-- Jalankan di: Supabase Dashboard > SQL Editor > New query > Run
-- Aman dijalankan ulang (idempotent). Jika tabel sudah ada, hanya
-- kolom/kebijakan yang kurang yang ditambahkan.
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
create policy "users_select_own" on public.users
  for select to authenticated using (id = auth.uid());
create policy "users_update_own" on public.users
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Klien hanya boleh mengubah kolom profil, bukan badge/pengikut
revoke update on public.users from anon, authenticated;
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

-- ---------- 5. DATA AWAL (6 karya dari data mock, status approved) ----------
-- Isi konten hanya ringkasan; ganti dengan isi karya yang sebenarnya.
insert into public.books (author, title, category, content, synopsis, tags, cover_asset,
                          approval_status, views_count, rating, total_chapters, created_at, approved_at)
select v.* from (values
  ('Leila S. Chudori', 'Laut Bercerita', 'Novel',
   'Kisah persahabatan dan perjuangan yang dituturkan lewat sudut pandang seorang aktivis mahasiswa.',
   'Kisah persahabatan dan perjuangan yang menyayat hati, dituturkan lewat sudut pandang seorang aktivis mahasiswa.',
   array['Novel','Romansa','Sejarah'], 'assets/images/Laut_Bercerita.png',
   'approved', 245000, 4.9, 28, timestamptz '2026-01-10', timestamptz '2026-01-12'),
  ('Pramoedya Ananta Toer', 'Bumi Manusia', 'Novel',
   'Kisah Minke, seorang pribumi yang bersekolah di HBS pada masa kolonial Hindia Belanda.',
   'Novel klasik tentang identitas, cinta, dan perlawanan terhadap penjajahan.',
   array['Novel','Sejarah','Klasik'], 'assets/images/Bumi_Manusia.png',
   'approved', 512000, 4.9, 40, timestamptz '2026-01-05', timestamptz '2026-01-07'),
  ('Sapardi Djoko Damono', 'Aku Ingin', 'Puisi',
   'Puisi cinta yang sederhana namun mendalam.',
   'Puisi cinta yang sederhana namun mendalam.',
   array['Puisi','Romansa'], 'assets/images/Aku_Ingin.png',
   'approved', 98000, 4.8, 1, timestamptz '2026-02-01', timestamptz '2026-02-02'),
  ('Dee Lestari', 'Filosofi Kopi', 'Cerpen',
   'Ben dan Jody, dua sahabat pemilik kedai kopi yang berusaha membuat secangkir kopi terbaik di dunia.',
   'Cerpen tentang persahabatan, ambisi, dan makna kesempurnaan.',
   array['Cerpen','Persahabatan'], 'assets/images/Filosofi_Kopi.png',
   'approved', 76000, 4.7, 1, timestamptz '2026-02-15', timestamptz '2026-02-16'),
  ('Henry Manampiring', 'Filosofi Teras', 'Novel',
   'Penerapan filosofi Stoa untuk menjalani hidup yang lebih tenang.',
   'Penerapan filosofi Stoa ala teras rumah untuk menjalani hidup yang lebih tenang.',
   array['Novel','Filosofi'], 'assets/images/Filosofi_Teras.png',
   'approved', 187000, 4.8, 20, timestamptz '2026-01-20', timestamptz '2026-01-22'),
  ('Sapardi Djoko Damono', 'Hujan Bulan Juni', 'Puisi',
   'Kerinduan yang disampaikan dengan penuh ketabahan dan kearifan.',
   'Hujan Bulan Juni menceritakan rasa cinta dan kerinduan yang teramat dalam namun disampaikan dengan penuh ketabahan, kebijaksanaan, serta kearifan.',
   array['Puisi','Romansa'], 'assets/images/Hujan_Bulan_Juni.png',
   'approved', 76000, 4.7, 1, timestamptz '2026-02-15', timestamptz '2026-02-16')
) as v(author, title, category, content, synopsis, tags, cover_asset,
       approval_status, views_count, rating, total_chapters, created_at, approved_at)
where not exists (select 1 from public.books b where b.title = v.title);
