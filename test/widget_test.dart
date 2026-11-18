import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/app_user.dart';
import 'package:boardmate/models/property.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/screens/tenant/home_logic.dart';
import 'package:boardmate/screens/tenant/home_tab.dart';
import 'package:boardmate/widgets/room_tabs.dart';

void main() {
  // Tests run offline, so don't download fonts.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Property place(String id, String name, double lat, {List<String> tags = const []}) => Property(
        id: id,
        landlordId: 'l1',
        name: name,
        latitude: lat,
        longitude: 118.7338,
        priceMin: 3000,
        priceMax: 4500,
        tags: tags,
      );

  final places = [
    place('far', 'Far House', 9.80, tags: ['Wi-Fi']),
    place('near', 'Near House', 9.777),
  ];
  final now = DateTime(2026, 11, 18, 12);
  final rooms = [
    Room(propertyId: 'near', landlordId: 'l1', name: 'Room 1', type: RoomType.solo, monthlyPrice: 3000,
        updatedAt: now.subtract(const Duration(hours: 2))),
    const Room(propertyId: 'near', landlordId: 'l1', name: 'Room 2', type: RoomType.solo, monthlyPrice: 2000, available: false),
    const Room(propertyId: 'far', landlordId: 'l1', name: 'Room 1', type: RoomType.solo, monthlyPrice: 2500),
  ];

  Widget home({String? school}) => CupertinoApp(
        home: HomeTab(
          profile: AppUser(uid: 'u1', name: 'nathan', role: UserRole.student, school: school),
          properties: Stream.value(places),
          rooms: Stream.value(rooms),
        ),
      );

  testWidgets('Home: live board, closest house first, search filters the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home(school: 'psu'));
    await tester.pump();

    expect(find.text('Near PSU right now'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    final near = tester.getTopLeft(find.text('Near House')).dy;
    final far = tester.getTopLeft(find.text('Far House')).dy;
    expect(near, lessThan(far));
    expect(find.text('2 houses · closest first'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'wi-fi');
    await tester.pump();
    expect(find.text('Far House'), findsOneWidget);
    expect(find.text('Near House'), findsNothing);
  });

  testWidgets('Without a school the board covers the whole city; a pill picks one', (tester) async {
    await tester.pumpWidget(home());
    await tester.pump();
    expect(find.text('In Puerto Princesa right now'), findsOneWidget);
    expect(find.text('2 houses · A to Z'), findsOneWidget);
  });

  testWidgets('Scrolling the list shrinks the header to a slim bar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home(school: 'psu'));
    await tester.pump();
    expect(find.text('Live'), findsOneWidget);

    await tester.drag(find.text('Near House'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Live'), findsNothing);
    expect(find.text('PSU · 2 open'), findsOneWidget);
  });

  test('Live board numbers', () {
    final stats = LiveStats.from(places, rooms, schoolById('psu'), now: now);
    expect(stats.open, 2);
    expect(stats.tiles, [true, false, true]); // near house's rooms first
    expect(stats.updatedToday, 1);
    expect(stats.cheapest, 2500); // the taken ₱2,000 room doesn't count
  });

  testWidgets('Tapping a room tab selects it', (tester) async {
    var selected = 0;
    await tester.pumpWidget(CupertinoApp(
      home: StatefulBuilder(
        builder: (context, setState) => RoomTabs(
          labels: const ['Room 1', 'Room 2', 'Room 3'],
          selectedIndex: selected,
          taken: const {2},
          onChanged: (i) => setState(() => selected = i),
        ),
      ),
    ));
    await tester.tap(find.text('Room 3'));
    await tester.pump();
    expect(selected, 2);
  });
}
