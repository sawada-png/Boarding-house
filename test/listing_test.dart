import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/property.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/screens/tenant/home_logic.dart';
import 'package:boardmate/screens/tenant/listing_screen.dart';
import 'package:boardmate/screens/tenant/share_house.dart';
import 'package:boardmate/services/landlord_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const house = Property(
    id: 'p1',
    landlordId: 'l1',
    name: "Neegy's Place",
    area: 'Mandaragat',
    latitude: 9.7768,
    longitude: 118.7338,
    priceMin: 500,
    priceMax: 1000,
    tags: ['Wi-Fi'],
  );

  Future<void> open(WidgetTester tester, List<Room> rooms) async {
    // Wide: the test font makes the map credit too long for a phone width.
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      CupertinoApp(
        home: ListingScreen(
          property: house,
          school: schoolById('psu'),
          userId: 'u1',
          rooms: Stream.value(rooms),
          savedIds: Stream.value(const []),
          landlord: const LandlordInfo(name: 'Nathan Grande', verified: true),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('House page with rooms: header, Room Map, tap a room, Plan a visit', (tester) async {
    await open(tester, const [
      Room(
        id: 'r1',
        propertyId: 'p1',
        landlordId: 'l1',
        name: 'Room 1',
        type: RoomType.bedspace,
        capacity: 2,
        monthlyPrice: 3500,
      ),
      Room(
        id: 'r2',
        propertyId: 'p1',
        landlordId: 'l1',
        name: 'Room 2',
        type: RoomType.solo,
        monthlyPrice: 4500,
        available: false,
        floor: RoomFloor.second,
      ),
    ]);

    expect(find.text('Mandaragat · Puerto Princesa'), findsOneWidget);
    expect(find.bySemanticsLabel('Share'), findsOneWidget);
    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    expect(find.text('1 min walk to PSU'), findsOneWidget);
    expect(find.text('New · no reviews yet'), findsOneWidget);
    expect(find.text('1 of 2 open'), findsOneWidget);
    expect(find.text('2F'), findsOneWidget);
    expect(find.text('GF'), findsOneWidget);
    expect(find.text('1 room open from'), findsOneWidget);
    expect(find.text('Plan a visit'), findsOneWidget);
    expect(find.text('Listed by Nathan'), findsOneWidget);
    expect(find.text('Verified owner'), findsOneWidget);

    // Tapping a room opens its sheet with the real monthly cost.
    await tester.tap(find.bySemanticsLabel('Room 2, taken'));
    await tester.pumpAndSettle();
    expect(find.text('2nd floor · solo room · shared CR'), findsOneWidget);
    expect(find.text('Real monthly cost'), findsOneWidget);
    expect(find.text('Ask about Room 2'), findsOneWidget);
    expect(find.text('Never send a deposit before you visit.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan a visit'));
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('House page with no rooms: empty Room Map, ask button, price range + Message', (tester) async {
    await open(tester, const []);
    expect(find.text('No rooms listed yet'), findsOneWidget);
    expect(find.text('Ask the owner which rooms are open'), findsOneWidget);
    expect(find.text('Price range'), findsOneWidget);
    expect(find.text('₱500–1,000 /mo', findRichText: true), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });

  test('Share text', () {
    final rooms = roomsByHouse(const [
      Room(propertyId: 'p1', landlordId: 'l1', name: 'Room 1', type: RoomType.solo, monthlyPrice: 3500),
      Room(propertyId: 'p1', landlordId: 'l1', name: 'Room 2', type: RoomType.solo, monthlyPrice: 3000),
    ])['p1'];
    expect(
      shareText(house, rooms, schoolById('psu')),
      "Neegy's Place · Mandaragat · Puerto Princesa\n2 rooms open from ₱3,000/month · 1 min walk to PSU\nFound on BoardMate",
    );
    expect(
      shareText(house, null, null),
      "Neegy's Place · Mandaragat · Puerto Princesa\n₱500–1,000/month\nFound on BoardMate",
    );
  });
}
