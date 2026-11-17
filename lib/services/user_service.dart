import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Reads and saves user profiles in Firestore (users/{uid}).
class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  /// The user's profile, or null if they haven't picked a role yet.
  Stream<AppUser?> watch(String uid) => _users.doc(uid).snapshots().map(
        (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
      );

  /// First-time setup after login: saves name and role.
  Future<void> create(User user, {required String name, required UserRole role}) {
    final profile = AppUser(
      uid: user.uid,
      name: name,
      role: role,
      phone: user.phoneNumber,
      email: user.email,
      loginType: loginTypeOf(user),
    );
    return _users.doc(user.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Switch between student mode and landlord mode.
  Future<void> setRole(String uid, UserRole role) =>
      _users.doc(uid).update({'role': role.name});
}

/// 'google', 'facebook' or 'phone', from how the user logged in.
String loginTypeOf(User user) {
  final ids = user.providerData.map((p) => p.providerId);
  if (ids.contains('google.com')) return 'google';
  if (ids.contains('facebook.com')) return 'facebook';
  return 'phone';
}
