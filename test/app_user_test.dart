import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/app_user.dart';

void main() {
  test('A user survives saving and loading', () {
    const user = AppUser(
      uid: 'u1',
      name: 'Nathan',
      role: UserRole.landlord,
      phone: '+639123456789',
      loginType: 'phone',
    );
    final loaded = AppUser.fromMap('u1', user.toMap());
    expect(loaded.name, 'Nathan');
    expect(loaded.role, UserRole.landlord);
    expect(loaded.phone, '+639123456789');
    expect(loaded.verified, isFalse);
  });

  test('Missing or unknown role falls back to student', () {
    expect(AppUser.fromMap('u1', {}).role, UserRole.student);
    expect(AppUser.fromMap('u1', {'role': 'admin'}).role, UserRole.student);
  });
}
