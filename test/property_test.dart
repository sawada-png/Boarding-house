import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/property.dart';
import 'package:boardmate/screens/landlord/property_form_screen.dart';

void main() {
  test('Prices are shown with commas', () {
    expect(formatPesos(500), '500');
    expect(formatPesos(3000), '3,000');
    expect(formatPesos(12500), '12,500');
    expect(formatPesos(1000000), '1,000,000');
    expect(formatPriceRange(3000, 4500), '₱3,000–4,500');
    expect(formatPriceRange(3500, 3500), '₱3,500');
  });

  test('Typed prices are read correctly', () {
    expect(parsePesos('3,000'), 3000);
    expect(parsePesos('₱ 4500'), 4500);
    expect(parsePesos(''), isNull);
    expect(parsePesos('abc'), isNull);
  });

  test('Property form catches missing or wrong info', () {
    String? check({
      String name = 'House',
      bool loc = true,
      int photos = 1,
      int? min = 3000,
      int? max = 4500,
    }) =>
        checkPropertyForm(
          name: name,
          hasLocation: loc,
          photoCount: photos,
          priceMin: min,
          priceMax: max,
        );

    expect(check(), isNull);
    expect(check(name: '  '), isNotNull);
    expect(check(photos: 0), isNotNull);
    expect(check(loc: false), isNotNull);
    expect(check(min: null), isNotNull);
    expect(check(min: 0), isNotNull);
    expect(check(min: 5000, max: 4000), isNotNull);
  });
}
