import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/screens/tenant/home_logic.dart';

void main() {
  test('Distance text', () {
    expect(formatDistance(447), '450 m');
    expect(formatDistance(996), '1.0 km');
    expect(formatDistance(1234), '1.2 km');
  });

  test('Walk time: 80 m per minute, far places show km', () {
    final psu = schoolById('psu')!;
    expect(walkMinutes(450), 6);
    expect(walkMinutes(10), 1);
    expect(walkText(450, psu), '6 min walk to PSU');
    expect(walkText(3200, psu), '40 min walk to PSU');
    expect(walkText(4000, psu), '4.0 km from PSU'); // over 45 min: show km
  });

  test('PSU and WPU are about 1 km apart', () {
    final m = metersBetween(schoolById('psu')!.location, schoolById('wpu')!.location);
    expect(m, inInclusiveRange(800, 1500));
    expect(schoolById('nope'), isNull);
  });

  test('Room numbers per boarding house', () {
    Room r(String p, bool open, int price) =>
        Room(propertyId: p, landlordId: 'l', name: 'R', type: RoomType.solo, monthlyPrice: price, available: open);
    final byHouse = roomsByHouse([r('a', true, 3000), r('a', true, 2500), r('a', false, 1000), r('b', false, 2000)]);
    expect(byHouse['a']!.open, 2);
    expect(byHouse['a']!.total, 3);
    expect(byHouse['a']!.cheapestOpen, 2500); // the taken ₱1,000 room doesn't count
    expect(byHouse['b']!.full, isTrue);
    expect(byHouse['b']!.cheapestOpen, isNull);
  });
}
