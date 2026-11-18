import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/room.dart';
import 'package:boardmate/screens/landlord/room_form_screen.dart';

void main() {
  Room room({
    RoomType type = RoomType.bedspace,
    int capacity = 2,
    bool privateCr = true,
    List<String> included = const ['Study table', 'Electric fan'],
  }) => Room(
    propertyId: 'p1',
    landlordId: 'u1',
    name: 'Room 1',
    type: type,
    capacity: capacity,
    monthlyPrice: 3500,
    privateCr: privateCr,
    included: included,
  );

  test('Room summary reads like the mockup', () {
    expect(room().summary, 'Bedspace for 2 · own CR · study table, electric fan');
    expect(room(type: RoomType.solo, privateCr: false, included: []).summary, 'Solo room · shared CR');
  });

  test('Solo rooms always save 1 person', () {
    expect(room(type: RoomType.solo, capacity: 4).toMap()['capacity'], 1);
    expect(room(capacity: 4).toMap()['capacity'], 4);
  });

  test('CR type is saved as private or shared', () {
    expect(room().toMap()['crType'], 'private');
    expect(room(privateCr: false).toMap()['crType'], 'shared');
  });

  test('Rooms sort by number, not by text', () {
    final names = ['Room 10', 'Room 2', 'Room 1', 'Attic'];
    names.sort(compareRoomNames);
    expect(names, ['Attic', 'Room 1', 'Room 2', 'Room 10']);
  });

  test('Room form catches missing or wrong info', () {
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: 3500), isNull);
    expect(checkRoomForm(name: ' ', photoCount: 1, price: 3500), isNotNull);
    expect(checkRoomForm(name: 'Room 1', photoCount: 0, price: 3500), isNotNull);
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: null), isNotNull);
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: 0), isNotNull);
  });
}
