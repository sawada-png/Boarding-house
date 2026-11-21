import 'package:cloud_firestore/cloud_firestore.dart';

/// What students may see about a landlord. Kept apart from users/{uid}, which stays private.
class LandlordInfo {
  const LandlordInfo({required this.name, this.verified = false, this.phone});

  final String name;

  /// ID checked by BoardMate staff (set in the Firebase console, never by the app).
  final bool verified;

  /// For the Call button in chat. Null if the landlord logged in without a phone number.
  final String? phone;

  String get firstName => name.trim().split(' ').first;
}

/// Public landlord profiles at landlords/{uid}: name, phone + verified badge.
class LandlordService {
  LandlordService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _landlords => _db.collection('landlords');

  static LandlordInfo _fromMap(Map<String, dynamic> d) => LandlordInfo(
    name: d['name'] as String? ?? '',
    verified: d['verified'] as bool? ?? false,
    phone: d['phone'] as String?,
  );

  /// landlordId → public info, for cards and house pages.
  // shortcut: loads every landlord; fine for one city, switch to per-house reads past a few hundred.
  Stream<Map<String, LandlordInfo>> watchAll() =>
      _landlords.snapshots().map((snap) => {for (final d in snap.docs) d.id: _fromMap(d.data())});

  /// One landlord, or null before they open landlord mode once.
  Stream<LandlordInfo?> watch(String uid) =>
      _landlords.doc(uid).snapshots().map((d) => d.exists ? _fromMap(d.data()!) : null);

  /// Creates or updates the landlord's public profile. Never touches "verified".
  Future<void> publish(String uid, String name, String? phone) =>
      _landlords.doc(uid).set({'name': name, 'phone': phone}, SetOptions(merge: true));
}
