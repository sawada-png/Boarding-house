import 'package:cloud_firestore/cloud_firestore.dart';

/// A student's review of a boarding house, saved at reviews/{stayId}: one per verified stay.
class Review {
  const Review({
    this.id = '',
    required this.propertyId,
    required this.studentId,
    required this.studentName,
    required this.roomName,
    required this.stars,
    required this.text,
    this.createdAt,
  });

  /// Same as the stay id.
  final String id;
  final String propertyId;
  final String studentId;
  final String studentName;
  final String roomName;

  /// 1 to 5.
  final int stars;
  final String text;
  final DateTime? createdAt;

  String get firstName => studentName.trim().split(' ').first;

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Review(
      id: doc.id,
      propertyId: d['propertyId'] as String? ?? '',
      studentId: d['studentId'] as String? ?? '',
      studentName: d['studentName'] as String? ?? '',
      roomName: d['roomName'] as String? ?? '',
      stars: (d['stars'] as num?)?.toInt() ?? 0,
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Longest review text allowed (the rules check it too).
const reviewMaxLength = 500;

/// "4.5" from the stars, or null with no reviews.
String? averageStars(List<Review> reviews) {
  if (reviews.isEmpty) return null;
  final avg = reviews.fold<int>(0, (total, r) => total + r.stars) / reviews.length;
  return avg.toStringAsFixed(1);
}
