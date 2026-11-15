// Membuat literal SQL isi karya "Laut Bercerita" dari novel lokal di
// `lib/app/data/novel_chapters.dart`, lalu menulisnya ke
// `supabase/.laut_content.sql`.
//
// Dipakai saat memperbarui seed `supabase/schema.sql` (section 5): file
// hasil ini menggantikan penanda __LAUT_BERCERITA_CONTENT__ supaya isi
// bab di database sama persis dengan yang dibaca aplikasi.
//
// Jalankan: dart run tool/gen_seed_content.dart
import 'dart:io';

import 'package:karyaku_app/app/data/novel_chapters.dart';

void main() {
  final content = NovelContent.lautBercerita
      .map((chapter) => '${chapter.number}|${chapter.title}\n\n${chapter.content.trim()}')
      .join('\n\n[[BAB]]\n\n');

  // Literal SQL: tanda kutip tunggal dilepaskan dengan menggandakannya.
  final escaped = content.replaceAll("'", "''");
  File('supabase/.laut_content.sql').writeAsStringSync(escaped);
  stdout.writeln(
      'Menulis supabase/.laut_content.sql (${escaped.length} karakter).');
}
