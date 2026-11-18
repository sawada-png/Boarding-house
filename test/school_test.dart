import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';

void main() {
  test('Distance text', () {
    expect(formatDistance(447), '450 m');
    expect(formatDistance(996), '1.0 km');
    expect(formatDistance(1234), '1.2 km');
  });

  test('PSU and WPU are about 1 km apart', () {
    final m = metersBetween(schoolById('psu')!.location, schoolById('wpu')!.location);
    expect(m, inInclusiveRange(800, 1500));
    expect(schoolById('nope'), isNull);
  });

  test('Counts available rooms per boarding house', () {
    Room r(String p, bool available) =>
        Room(propertyId: p, landlordId: 'l', name: 'R', type: RoomType.solo, monthlyPrice: 1, available: available);
    expect(countAvailableRooms([r('a', true), r('a', false), r('b', false)]), {'a': 1, 'b': 0});
  });
}
