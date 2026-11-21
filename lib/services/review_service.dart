import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';
import '../models/stay.dart';

/// Reviews at reviews/{stayId}. Only a student with a verified stay can write one (checked by the rules).
class ReviewService {
  ReviewService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _reviews => _db.collection('reviews');

  /// Newest first.
  Stream<List<Review>> watchForProperty(String propertyId) =>
      _reviews.where('propertyId', isEqualTo: propertyId).snapshots().map((s) {
        final far = DateTime(2000);
        return s.docs.map(Review.fromDoc).toList()..sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
      });

  Stream<List<Review>> watchMine(String uid) =>
      _reviews.where('studentId', isEqualTo: uid).snapshots().map((s) => s.docs.map(Review.fromDoc).toList());

  /// Writes or replaces the review for [stay].
  Future<void> save(Stay stay, {required int stars, required String text}) => _reviews.doc(stay.id).set({
    'propertyId': stay.propertyId,
    'studentId': stay.studentId,
    'studentName': stay.studentName,
    'roomName': stay.roomName,
    'stars': stars,
    'text': text.trim(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}
