import 'package:cloud_firestore/cloud_firestore.dart';

enum BackupType { image, document, note }

class BackupItem {
  final String id;
  final String title;
  final String? content; // For notes
  final String? fileUrl; // For images/docs
  final double fileSize; // IN MB
  final BackupType type;
  final DateTime createdAt;
  final bool isPublic;

  BackupItem({
    required this.id,
    required this.title,
    this.content,
    this.fileUrl,
    this.fileSize = 0.5, // Default if not found
    required this.type,
    required this.createdAt,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'fileUrl': fileUrl,
    'fileSize': fileSize,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'isPublic': isPublic,
  };

  factory BackupItem.fromMap(Map<String, dynamic> map, String docId) {
    return BackupItem(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'],
      fileUrl: map['fileUrl'],
      fileSize: (map['fileSize'] ?? 0.5).toDouble(),
      type: BackupType.values.firstWhere((e) => e.name == map['type'], orElse: () => BackupType.note),
      createdAt: _parseDateTimeNullable(map['createdAt']) ?? DateTime.now(),
      isPublic: map['isPublic'] ?? false,
    );
  }

  /// Helper to parse nullable DateTime from both Timestamp and DateTime objects
  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
