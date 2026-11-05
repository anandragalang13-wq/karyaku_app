import 'book_covers.dart';
import 'models/book_model.dart';
import 'models/work_model.dart'; 
import 'package:karyaku_app/app/data/models/work_model_exension.dart';

class MockWorksData {
  MockWorksData._();

  static final List<WorkModel> _allWorks = [
    WorkModel(
      id: 'laut-bercerita',
      authorId: 'leila-s-chudori',
      title: 'Laut Bercerita',
      type: WorkType.novel,
      cover: 'assets/images/Laut_Bercerita.png',
      content: 'Sebuah kisah tentang persahabatan, cinta, dan perjuangan '
          'di tengah gejolak politik Indonesia akhir era 1990-an.',
      synopsis: 'Kisah persahabatan dan perjuangan yang menyayat hati, '
          'dituturkan lewat sudut pandang seorang aktivis mahasiswa.',
      tags: const ['Novel', 'Romansa', 'Sejarah'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 1, 10),
      submittedAt: DateTime(2026, 1, 11),
      approvedAt: DateTime(2026, 1, 12),
      views: 245000,
      rating: 4.9,
      chapterCount: 28,
    ),
    WorkModel(
      id: 'bumi-manusia',
      authorId: 'pramoedya-ananta-toer',
      title: 'Bumi Manusia',
      type: WorkType.novel,
      cover: 'assets/images/Bumi_Manusia.png',
      content: 'Kisah Minke, seorang pribumi yang bersekolah di HBS pada '
          'masa kolonial Hindia Belanda.',
      synopsis: 'Novel klasik tentang identitas, cinta, dan perlawanan '
          'terhadap penjajahan.',
      tags: const ['Novel', 'Sejarah', 'Klasik'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 1, 5),
      submittedAt: DateTime(2026, 1, 6),
      approvedAt: DateTime(2026, 1, 7),
      views: 512000,
      rating: 4.9,
      chapterCount: 40,
    ),
    WorkModel(
      id: 'aku-ingin',
      authorId: 'sapardi-djoko-damono',
      title: 'Aku Ingin',
      type: WorkType.puisi,
      cover: 'assets/images/Aku_Ingin.png',
      content: 'Aku ingin mencintaimu dengan sederhana...',
      synopsis: 'Puisi cinta yang sederhana namun mendalam.',
      tags: const ['Puisi', 'Romansa'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 2, 1),
      submittedAt: DateTime(2026, 2, 1),
      approvedAt: DateTime(2026, 2, 2),
      views: 98000,
      rating: 4.8,
      chapterCount: 1,
    ),
    WorkModel(
      id: 'filosofi-kopi',
      authorId: 'dewi-lestari',
      title: 'Filosofi Kopi',
      type: WorkType.cerpen,
      cover: 'assets/images/Filosofi_Kopi.png',
      content: 'Ben dan Jody, dua sahabat pemilik kedai kopi yang '
          'berusaha membuat secangkir kopi terbaik di dunia.',
      synopsis: 'Cerpen tentang persahabatan, ambisi, dan makna '
          'kesempurnaan.',
      tags: const ['Cerpen', 'Persahabatan'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 2, 15),
      submittedAt: DateTime(2026, 2, 15),
      approvedAt: DateTime(2026, 2, 16),
      views: 76000,
      rating: 4.7,
      chapterCount: 1,
    ),
    WorkModel(
      id: 'filosofi-teras',
      authorId: 'henry-manampiring',
      title: 'Filosofi Teras',
      type: WorkType.novel,
      cover: 'assets/images/Filosofi_Teras.png',
      content: 'Karena hidup bukan hanya tentang menjadi, tapi juga '
          'tentang memahami.',
      synopsis: 'Penerapan filosofi Stoa ala teras rumah untuk '
          'menjalani hidup yang lebih tenang.',
      tags: const ['Novel', 'Filosofi'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 1, 20),
      submittedAt: DateTime(2026, 1, 21),
      approvedAt: DateTime(2026, 1, 22),
      views: 187000,
      rating: 4.8,
      chapterCount: 20,
    ),
    WorkModel(
      id: 'hujan-bulan-juni',
      authorId: 'sapardi-djoko-damono',
      title: 'Hujan Bulan Juni',
      type: WorkType.puisi,
      cover: 'assets/images/Hujan_Bulan_Juni.png',
      content: '''tak ada yang lebih tabah
dari hujan bulan juni
dirahasiakannya rintik rindu-nya
kepada pohon berbunga itu''',
      synopsis:
          'Hujan Bulan Juni menceritakan tentang rasa cinta dan kerinduan yang teramat dalam namun disampaikan dengan penuh ketabahan, kebijaksanaan, serta kearifan.',
      tags: const ['Puisi', 'Romansa'],
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime(2026, 2, 15),
      submittedAt: DateTime(2026, 2, 15),
      approvedAt: DateTime(2026, 2, 16),
      views: 76000,
      rating: 4.7,
      chapterCount: 1,
    ),
    WorkModel(
      id: 'menantikan-hujan',
      authorId: 'anandra-galang',
      title: 'Menantikan Hujan',
      type: WorkType.puisi,
      cover: BookCovers.hujanBulanJuni,
      content: 'Hujan turun perlahan, membasahi rindu yang tertunda...',
      synopsis: 'Kumpulan puisi tentang penantian dan harapan.',
      tags: const ['Puisi', 'Alam'],
      approvalStatus: ApprovalStatus.pending,
      createdAt: DateTime(2026, 3, 1),
      submittedAt: DateTime(2026, 3, 2),
      views: 0,
      rating: 0.0,
      chapterCount: 1,
    ),
    WorkModel(
      id: 'catatan-perjalanan',
      authorId: 'anandra-galang',
      title: 'Catatan Perjalanan',
      type: WorkType.cerpen,
      cover: BookCovers.senjaDiPelantara,
      content: 'Draft belum selesai...',
      synopsis: null,
      tags: const ['Cerpen'],
      approvalStatus: ApprovalStatus.draft,
      createdAt: DateTime(2026, 3, 10),
      views: 0,
      rating: 0.0,
      chapterCount: 1,
    ),
  ];

  static List<WorkModel> getAllWorks() => List<WorkModel>.from(_allWorks);

  static List<WorkModel> getApprovedWorks() => _allWorks
      .where((work) => work.approvalStatus == ApprovalStatus.approved)
      .toList();

  static List<WorkModel> getWorksByType(WorkType type) =>
      _allWorks.where((work) => work.type == type).toList();

  static List<WorkModel> getWorksByAuthor(String authorId) =>
      _allWorks.where((work) => work.authorId == authorId).toList();

  static List<BookModel> getApprovedWorksAsBooks() =>
      getApprovedWorks().map((work) => work.toBookModel()).toList();
}