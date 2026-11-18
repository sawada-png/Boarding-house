import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/app_user.dart';
import 'package:boardmate/models/property.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/services/landlord_service.dart';
import 'package:boardmate/screens/tenant/home_logic.dart';
import 'package:boardmate/screens/tenant/home_tab.dart';
import 'package:boardmate/widgets/room_dots.dart';

void main() {
  // Tests run offline, so don't download fonts.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Property place(String id, String name, double lat, {List<String> tags = const [], String area = ''}) => Property(
    id: id,
    landlordId: 'l1',
    name: name,
    latitude: lat,
    longitude: 118.7338,
    priceMin: 3000,
    priceMax: 4500,
    tags: tags,
    area: area,
  );

  // PSU is at 9.7768. About 0 m, 900 m, 650 m and 3.5 km away.
  final places = [
    place('walk', 'Walkable House', 9.785, tags: ['Wi-Fi'], area: 'Tiniguiban'),
    place('near', 'Near House', 9.777),
    place('full', 'Full House', 9.7826),
    place('far', 'Far House', 9.808),
  ];
  final now = DateTime(2026, 11, 18, 12);
  final rooms = [
    Room(
      propertyId: 'near',
      landlordId: 'l1',
      name: 'Room 1',
      type: RoomType.solo,
      monthlyPrice: 3000,
      openedAt: now.subtract(const Duration(hours: 2)),
    ),
    const Room(
      propertyId: 'near',
      landlordId: 'l1',
      name: 'Room 2',
      type: RoomType.solo,
      monthlyPrice: 2000,
      available: false,
    ),
    const Room(propertyId: 'walk', landlordId: 'l1', name: 'Room 1', type: RoomType.solo, monthlyPrice: 2500),
    const Room(
      propertyId: 'full',
      landlordId: 'l1',
      name: 'Room 1',
      type: RoomType.solo,
      monthlyPrice: 1500,
      available: false,
    ),
    const Room(propertyId: 'far', landlordId: 'l1', name: 'Room 1', type: RoomType.solo, monthlyPrice: 1000),
  ];

  Widget home({String? school}) => CupertinoApp(
    home: HomeTab(
      profile: AppUser(uid: 'u1', name: 'nathan', role: UserRole.student, school: school),
      properties: Stream.value(places),
      rooms: Stream.value(rooms),
      savedIds: Stream.value(const ['walk']),
      landlords: Stream.value(const {'l1': LandlordInfo(name: 'Nathan Grande', verified: true)}),
    ),
  );

  // The Live dot pulses forever, so wait a fixed time instead of "until everything stops".
  Future<void> settle(WidgetTester tester) => tester.pump(const Duration(seconds: 1));

  testWidgets('Home: houses within a 20 min walk, by walk time, full ones last', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home(school: 'psu'));
    await settle(tester);

    expect(find.text('Near PSU right now'), findsOneWidget);
    expect(find.text('3 houses · sorted by walk time'), findsOneWidget);
    expect(find.text('Far House'), findsNothing); // 3.5 km is too far to walk
    double y(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(y('Near House'), lessThan(y('Walkable House')));
    expect(y('Walkable House'), lessThan(y('Full House'))); // full goes last even though it's closer
    expect(find.text('Full'), findsOneWidget);
    expect(find.text('1 of 2 open'), findsOneWidget);
    expect(find.text('New · Tiniguiban · Verified owner'), findsOneWidget);
    expect(find.textContaining('min walk to PSU'), findsNWidgets(3));
    expect(find.bySemanticsLabel('Saved. Tap to remove'), findsOneWidget);
  });

  testWidgets('Search matches name, area and tags', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home(school: 'psu'));
    await settle(tester);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'tiniguiban');
    await settle(tester);
    expect(find.text('Walkable House'), findsOneWidget);
    expect(find.text('Near House'), findsNothing);
  });

  testWidgets('Without a school the whole city shows', (tester) async {
    await tester.pumpWidget(home());
    await settle(tester);
    expect(find.text('In Puerto Princesa right now'), findsOneWidget);
    expect(find.text('4 houses · A to Z'), findsOneWidget);
  });

  testWidgets('Scrolling the list shrinks the header to a slim bar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(home(school: 'psu'));
    await settle(tester);
    expect(find.text('Live'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await settle(tester);
    expect(find.text('Live'), findsNothing);
    expect(find.text('PSU · 2 open'), findsOneWidget);
  });

  test('Live board numbers', () {
    final stats = LiveStats.from(places, rooms, schoolById('psu'), now: now);
    expect(stats.open, 2); // the far house's room is not "near"
    expect(stats.tiles, [true, false, false, true]); // closest house's rooms first
    expect(stats.openedToday, 1);
    expect(stats.cheapest, 2500); // taken rooms don't count
  });

  testWidgets('Room dots: one square per room, label says how many are open', (tester) async {
    await tester.pumpWidget(const CupertinoApp(home: Center(child: RoomDots(open: 2, total: 5))));
    expect(find.text('2 of 5 rooms open'), findsOneWidget);
    final squares = find.descendant(of: find.byType(RoomDots), matching: find.byType(Container));
    expect(squares, findsNWidgets(5));
  });
}
