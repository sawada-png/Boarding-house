import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/models/room.dart';
import 'package:boardmate/screens/landlord/room_costs_card.dart';
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

  test('Room form checks the bill amounts only when they are needed', () {
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: 3500, electricityEstimate: null), isNotNull);
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: 3500, wifiPrice: 0), isNotNull);
    expect(checkRoomForm(name: 'Room 1', photoCount: 1, price: 3500, electricityEstimate: 400, wifiPrice: 150), isNull);
  });

  test('About ₱X /mo adds own-meter electricity and paid Wi-Fi to the rent', () {
    const base = Room(propertyId: 'p', landlordId: 'l', name: 'R', type: RoomType.solo, monthlyPrice: 3500);
    expect(base.estimatedMonthly, 3500); // old rooms: bills included, no Wi-Fi
    const withBills = Room(
      propertyId: 'p',
      landlordId: 'l',
      name: 'R',
      type: RoomType.solo,
      monthlyPrice: 3500,
      electricity: ElectricityCost.ownMeter,
      electricityEstimate: 400,
      water: WaterCost.separate,
      wifi: WifiCost.paid,
      wifiPrice: 150,
    );
    expect(withBills.estimatedMonthly, 4050); // like the mockup
    expect(withBills.toMap()['electricity'], 'ownMeter');
    expect(withBills.toMap()['wifiPrice'], 150);
    // A price typed for a bill that's switched back to "included" isn't saved.
    const switchedBack = Room(
      propertyId: 'p',
      landlordId: 'l',
      name: 'R',
      type: RoomType.solo,
      monthlyPrice: 3500,
      electricityEstimate: 400,
      wifiPrice: 150,
    );
    expect(switchedBack.estimatedMonthly, 3500);
    expect(switchedBack.toMap()['electricityEstimate'], 0);
  });

  test('Move-in terms shorten to fit the form row', () {
    expect(shortMoveIn('1 month deposit + 1 month advance'), '1 deposit + 1 advance');
    expect(shortMoveIn('2 months deposit + 1 month advance'), '2 deposit + 1 advance');
  });
}
