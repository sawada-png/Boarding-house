import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/property.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/screens/tenant/listing_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Listing shows info, room tabs switch rooms, Message says coming soon', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600)); // wide: the test font makes the map credit too long
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(CupertinoApp(
      home: ListingScreen(
        property: const Property(
          id: 'p1',
          landlordId: 'l1',
          name: "Nathan's Boarding House",
          latitude: 9.7768,
          longitude: 118.7338,
          priceMin: 3000,
          priceMax: 4500,
          tags: ['Wi-Fi', 'Girls only'],
        ),
        school: schoolById('psu'),
        rooms: Stream.value(const [
          Room(propertyId: 'p1', landlordId: 'l1', name: 'Room 1', type: RoomType.bedspace, capacity: 2, monthlyPrice: 3500),
          Room(propertyId: 'p1', landlordId: 'l1', name: 'Room 2', type: RoomType.solo, monthlyPrice: 4500, available: false),
        ]),
      ),
    ));
    await tester.pump();

    expect(find.text("Nathan's Boarding House"), findsOneWidget);
    expect(find.text('0 m from PSU Tiniguiban'), findsOneWidget);
    expect(find.text('Girls only'), findsOneWidget);
    expect(find.text('1 of 2 available'), findsOneWidget);
    expect(find.textContaining('per person'), findsOneWidget);

    await tester.tap(find.text('Room 2'));
    await tester.pump();
    expect(find.text('Taken'), findsOneWidget);
    expect(find.textContaining('Solo room'), findsOneWidget);

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
