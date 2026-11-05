import 'package:flutter/material.dart';

/// Status approval karya
enum ApprovalStatus {
  draft,         // Belum dikirim (hanya di draft)
  pending,       // Menunggu approval admin
  approved,      // Sudah diapprove, bisa dipublish
  rejected;      // Ditolak admin

  String get label {
    switch (this) {
      case ApprovalStatus.draft:
        return 'Draft';
      case ApprovalStatus.pending:
        return 'Menunggu Approval';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Ditolak';
    }
  }

  Color get color {
    switch (this) {
      case ApprovalStatus.draft:
        return Colors.grey;
      case ApprovalStatus.pending:
        return Colors.orange;
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ApprovalStatus.draft:
        return Icons.edit;
      case ApprovalStatus.pending:
        return Icons.hourglass_bottom;
      case ApprovalStatus.approved:
        return Icons.check_circle;
      case ApprovalStatus.rejected:
        return Icons.cancel;
    }
  }
}

/// Tipe karya: Novel, Puisi, Cerpen
enum WorkType {
  novel,
  puisi,
  cerpen;

  String get label {
    switch (this) {
      case WorkType.novel:
        return 'Novel';
      case WorkType.puisi:
        return 'Puisi';
      case WorkType.cerpen:
        return 'Cerpen';
    }
  }

  bool get needsCover => this != WorkType.puisi;
}

/// Model karya sastra
class WorkModel {
  final String id;
  final String authorId;
  final String? authorName; // nama tampilan penulis (dari kolom `author`)
  final String title;
  final WorkType type; // Novel, Puisi, Cerpen
  final String? cover; // URL cover image (nullable untuk puisi)
  final String content;
  final String? synopsis;
  final List<String> tags;
  final ApprovalStatus approvalStatus;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final int views;
  final double rating;
  final int chapterCount; // For novel/cerpen

  WorkModel({
    required this.id,
    required this.authorId,
    this.authorName,
    required this.title,
    required this.type,
    this.cover,
    required this.content,
    this.synopsis,
    required this.tags,
    this.approvalStatus = ApprovalStatus.draft,
    this.rejectionReason,
    required this.createdAt,
    this.submittedAt,
    this.approvedAt,
    this.views = 0,
    this.rating = 0.0,
    this.chapterCount = 1,
  });

  /// Cek apakah karya bisa di-submit untuk approval
  bool canSubmit() => approvalStatus == ApprovalStatus.draft;

  /// Cek apakah karya sudah bisa dipublish
  bool canPublish() => approvalStatus == ApprovalStatus.approved;

  /// Cek apakah masih bisa diedit
  bool canEdit() => 
    approvalStatus == ApprovalStatus.draft || 
    approvalStatus == ApprovalStatus.rejected;

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      type: WorkType.values.byName(json['type'] as String),
      cover: json['cover'] as String?,
      content: json['content'] as String,
      synopsis: json['synopsis'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      approvalStatus: ApprovalStatus.values
          .byName(json['approval_status'] as String? ?? 'draft'),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at'] as String) 
          : null,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at'] as String) 
          : null,
      views: json['views'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      chapterCount: json['chapter_count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author_id': authorId,
    'title': title,
    'type': type.name,
    'cover': cover,
    'content': content,
    'synopsis': synopsis,
    'tags': tags,
    'approval_status': approvalStatus.name,
    'rejection_reason': rejectionReason,
    'created_at': createdAt.toIso8601String(),
    'submitted_at': submittedAt?.toIso8601String(),
    'approved_at': approvedAt?.toIso8601String(),
    'views': views,
    'rating': rating,
    'chapter_count': chapterCount,
  };
}