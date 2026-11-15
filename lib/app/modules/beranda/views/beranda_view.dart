import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/work_model.dart';
import '../../../theme/app_colors.dart';
import '../controllers/beranda_controller.dart';

// ============================================================
// COVER BUKU — bisa dari asset lokal (assets/images/...) atau
// URL jaringan, tergantung isi field `cover` di WorkModel.
// ============================================================

Widget buildWorkCover(
  WorkModel work, {
  required double width,
  required double height,
}) {
  final cover = work.cover;

  if (cover == null || cover.isEmpty) {
    return _CoverPlaceholder(work: work, width: width, height: height);
  }

  final isLocalAsset = cover.startsWith('assets/');

  final Widget image = isLocalAsset
      ? Image.asset(
          cover,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _CoverPlaceholder(work: work, width: width, height: height);
          },
        )
      : Image.network(
          cover,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _CoverPlaceholder(work: work, width: width, height: height);
          },
        );

  return image;
}

class BerandaView extends GetView<BerandaController> {
  const BerandaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _BerandaBody(
          controller: controller,
        ),
      ),
    );
  }
}

class _BerandaBody extends StatefulWidget {
  final BerandaController controller;

  const _BerandaBody({
    required this.controller,
  });

  @override
  State<_BerandaBody> createState() => _BerandaBodyState();
}

// Sentinel key internal (bukan teks tampilan) untuk chip genre "Untuk Anda".
const String _kForYouKey = '__for_you__';

// Label yang ditampilkan untuk sebuah genre (menerjemahkan sentinel).
String _genreLabel(String genre) {
  return genre == _kForYouKey ? 'home_for_you'.tr : genre;
}

class _BerandaBodyState extends State<_BerandaBody> {
  int _selectedGenreIndex = 0;

  // Pencarian langsung (live search) di halaman Beranda.
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_onSearchFocusChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) => setState(() {});

  void _onSearchFocusChanged() => setState(() {});

  /// Membersihkan kata kunci & menutup hasil pencarian.
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {});
  }

  /// Mengetuk salah satu hasil pencarian → buka detail karya langsung.
  void _openResult(WorkModel work) {
    _clearSearch();
    widget.controller.openWorkDetail(work);
  }

  // ============================================================
  // MEMBUAT DAFTAR GENRE
  // ============================================================

  List<String> _buildGenres(List<WorkModel> works) {
    final freq = <String, int>{};

    for (final work in works) {
      for (final tag in work.tags) {
        freq[tag] = (freq[tag] ?? 0) + 1;
      }
    }

    final sortedTags = freq.keys.toList()
      ..sort(
        (a, b) => freq[b]!.compareTo(freq[a]!),
      );

    return [
      _kForYouKey,
      ...sortedTags.take(4),
    ];
  }



  // ============================================================
  // PILIHAN TERBAIK
  // ============================================================

  List<WorkModel> _forYouWorks(
    List<WorkModel> allWorks,
    String genre,
  ) {
    if (genre == _kForYouKey) {
      return allWorks.take(6).toList();
    }

    return allWorks
        .where(
          (work) => work.tags.contains(genre),
        )
        .take(6)
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final allWorks = widget.controller.allWorks;

      // ========================================================
      // GENRE
      // ========================================================

      final genres = _buildGenres(allWorks);

      final safeGenreIndex =
          genres.isEmpty
              ? 0
              : (_selectedGenreIndex < genres.length
                  ? _selectedGenreIndex
                  : 0);

      // ========================================================
      // PILIHAN TERBAIK
      // ========================================================

      final forYouWorks = genres.isEmpty
          ? <WorkModel>[]
          : _forYouWorks(
              allWorks,
              genres[safeGenreIndex],
            );

      // ========================================================
      // PALING POPULER
      // ========================================================
      //
      // Menggunakan karya yang sama dari database.
      // Tidak memakai sublist(4), supaya tidak kosong.
      //
      final popularWorks = allWorks.take(10).toList();

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            _TopHeader(
              onSearch: widget.controller.openSearch,
            ),

            const SizedBox(height: 22),

            // ==================================================
            // PILIHAN TERBAIK
            // ==================================================

            _SectionHeader(
              title: 'home_best_picks'.tr,
            ),

            const SizedBox(height: 12),

            // GENRE
            if (genres.isNotEmpty)
              _GenreChips(
                genres: genres,
                selectedIndex: safeGenreIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedGenreIndex = index;
                  });
                },
              ),

            const SizedBox(height: 16),

            // KARYA PILIHAN
            _WorkHorizontalList(
              works: forYouWorks,
              onTap: widget.controller.openWorkDetail,
            ),

            const SizedBox(height: 30),

            // ==================================================
            // PALING POPULER
            // ==================================================

            _SectionHeader(
              title: 'home_most_popular'.tr,
            ),

            const SizedBox(height: 16),

            // GRID PERINGKAT 2 KOLOM
            _PopularWorkGrid(
              works: popularWorks,
              onTap: widget.controller.openWorkDetail,
            ),

            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }
}

// ============================================================
// HEADER
// ============================================================

class _TopHeader extends StatelessWidget {
  final VoidCallback onSearch;

  const _TopHeader({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // LOGO KARYAKU
              Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Icon(
                    Icons.auto_stories,
                    size: 40,
                    color: AppColors.accentBlue,
                  );
                },
              ),

              const SizedBox(width: 10),

              // NAMA APLIKASI
              Text(
                'KARYAKU',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              // SEARCH — membuka halaman Temukan untuk mencari karya.
              InkWell(
                onTap: onSearch,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryNavy,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // KOLOM PENCARIAN — mengetuknya langsung membawa user ke
          // halaman Temukan supaya bisa mengetik kata kunci.
          InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'search_hint'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // GARIS BIRU
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ============================================================
// GENRE CHIPS
// ============================================================

class _GenreChips extends StatelessWidget {
  final List<String> genres;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _GenreChips({
    required this.genres,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final selected =
              index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 8,
              right:
                  index == genres.length - 1
                      ? 20
                      : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentBlue
                          .withOpacity(0.15)
                      : Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: selected
                      ? Border.all(
                          color:
                              AppColors.accentBlue,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Text(
                  _genreLabel(genres[index]),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? AppColors.accentBlue
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// LIST KARYA HORIZONTAL
// ============================================================

class _WorkHorizontalList extends StatelessWidget {
  final List<WorkModel> works;
  final ValueChanged<WorkModel> onTap;

  const _WorkHorizontalList({
    required this.works,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'home_no_works'.tr,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      // SAMA DENGAN KARTU PILIHAN TERBAIK
      height: 220,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: works.length,

        itemBuilder: (context, index) {
          final work = works[index];

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 12,
              right:
                  index == works.length - 1
                      ? 20
                      : 0,
            ),

            child: GestureDetector(
              onTap: () => onTap(work),

              child: SizedBox(
                // UKURAN KARTU SAMA
                width: 112,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // COVER BUKU
                    // ==================================================

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10),
                      child: buildWorkCover(
                        work,
                        width: 112,
                        height: 150,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ==================================================
                    // JUDUL
                    // ==================================================

                    Text(
                      work.title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // ==================================================
                    // GENRE
                    // ==================================================

                    Text(
                      work.tags.isNotEmpty
                          ? work.tags.first
                          : work.authorId,

                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER COVER
// ============================================================

class _CoverPlaceholder extends StatelessWidget {
  final WorkModel work;
  final double width;
  final double height;

  const _CoverPlaceholder({
    required this.work,
    this.width = 112,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Icon(
        work.type == WorkType.puisi
            ? Icons.edit_note
            : Icons.auto_stories,
        size: width * 0.32,
        color: Colors.grey.shade600,
      ),
    );
  }
}

// ============================================================
// GRID "PALING POPULER" — 2 KOLOM DENGAN BADGE PERINGKAT
// ============================================================

class _PopularWorkGrid extends StatelessWidget {
  final List<WorkModel> works;
  final ValueChanged<WorkModel> onTap;

  const _PopularWorkGrid({
    required this.works,
    required this.onTap,
  });

  // Warna badge peringkat, diulang bergantian seperti pada referensi.
  static const List<Color> _rankColors = [
    AppColors.accentOrange,
    AppColors.primaryNavy,
    AppColors.accentGreen,
    AppColors.accentPurple,
    AppColors.textMuted,
    AppColors.danger,
  ];

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'home_no_works'.tr,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    // Susun jadi baris berisi 2 karya (kiri & kanan) seperti referensi.
    final rows = <Widget>[];
    for (var i = 0; i < works.length; i += 2) {
      final left = works[i];
      final leftTile = _PopularWorkTile(
        rank: i + 1,
        work: left,
        color: _rankColors[i % _rankColors.length],
        onTap: () => onTap(left),
      );

      Widget rightTile = const SizedBox.shrink();
      if (i + 1 < works.length) {
        final right = works[i + 1];
        rightTile = _PopularWorkTile(
          rank: i + 2,
          work: right,
          color: _rankColors[(i + 1) % _rankColors.length],
          onTap: () => onTap(right),
        );
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftTile),
              const SizedBox(width: 16),
              Expanded(child: rightTile),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: rows),
    );
  }
}

class _PopularWorkTile extends StatelessWidget {
  final int rank;
  final WorkModel work;
  final Color color;
  final VoidCallback onTap;

  const _PopularWorkTile({
    required this.rank,
    required this.work,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // THUMBNAIL + BADGE PERINGKAT
          // ============================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildWorkCover(work, width: 64, height: 86),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // ============================================
          // JUDUL + SUBJUDUL
          // ============================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  work.tags.isNotEmpty ? work.tags.first : work.authorId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}