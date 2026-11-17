enum UserRole { student, landlord }

/// A BoardMate user, saved in Firestore at users/{uid}.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    this.phone,
    this.email,
    this.loginType = 'phone',
    this.school,
    this.verified = false,
  });

  final String uid;
  final String name;
  final UserRole role;
  final String? phone;
  final String? email;

  /// 'phone', 'google' or 'facebook'.
  final String loginType;

  /// Picked in Week 2.
  final String? school;

  /// Landlord ID check. Only BoardMate staff can turn this on.
  final bool verified;

  bool get isLandlord => role == UserRole.landlord;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        name: data['name'] as String? ?? '',
        role: data['role'] == 'landlord' ? UserRole.landlord : UserRole.student,
        phone: data['phone'] as String?,
        email: data['email'] as String?,
        loginType: data['loginType'] as String? ?? 'phone',
        school: data['school'] as String?,
        verified: data['verified'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role.name,
        'phone': phone,
        'email': email,
        'loginType': loginType,
        'school': school,
        'verified': verified,
      };
}
