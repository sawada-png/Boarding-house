import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/services/auth_service.dart';

void main() {
  test('PH mobile numbers are cleaned up to +63 format', () {
    expect(normalizePhPhone('0912 345 6789'), '+639123456789');
    expect(normalizePhPhone('912-345-6789'), '+639123456789');
    expect(normalizePhPhone('+63 912 345 6789'), '+639123456789');
    expect(normalizePhPhone('639123456789'), '+639123456789');
  });

  test('Bad numbers are rejected', () {
    expect(normalizePhPhone(''), isNull);
    expect(normalizePhPhone('0912 345'), isNull);
    expect(normalizePhPhone('0812 345 6789'), isNull); // must start with 9
    expect(normalizePhPhone('0912 345 67890'), isNull);
  });
}
