import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String productId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.productId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userImageUrl: map['userImageUrl'] ?? '',
      productId: map['productId'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Helper to parse DateTime from both Timestamp and DateTime objects
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'productId': productId,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
