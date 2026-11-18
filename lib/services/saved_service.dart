import 'package:cloud_firestore/cloud_firestore.dart';

/// Hearted boarding houses, saved in Firestore at saved/{userId}_{propertyId}.
class SavedService {
  SavedService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _saved => _db.collection('saved');

  static String docId(String userId, String propertyId) => '${userId}_$propertyId';

  /// The user's saved house ids, newest first.
  // Sorted here (not by Firestore) so no extra database index is needed.
  Stream<List<String>> watchIds(String userId) => _saved.where('userId', isEqualTo: userId).snapshots().map((snap) {
    final docs = [...snap.docs]
      ..sort((a, b) {
        final ta = a.data()['savedAt'] as Timestamp?;
        final tb = b.data()['savedAt'] as Timestamp?;
        // Just-saved items have no server time yet: keep them on top.
        if (ta == null) return -1;
        if (tb == null) return 1;
        return tb.compareTo(ta);
      });
    return [for (final d in docs) d.data()['propertyId'] as String];
  });

  /// Saves or unsaves, and moves the house's public save count by 1 in the same write.
  Future<void> setSaved({required String userId, required String propertyId, required bool saved}) {
    final batch = _db.batch();
    final doc = _saved.doc(docId(userId, propertyId));
    if (saved) {
      batch.set(doc, {'userId': userId, 'propertyId': propertyId, 'savedAt': FieldValue.serverTimestamp()});
    } else {
      batch.delete(doc);
    }
    batch.update(_db.collection('properties').doc(propertyId), {'saveCount': FieldValue.increment(saved ? 1 : -1)});
    return batch.commit();
  }
}
