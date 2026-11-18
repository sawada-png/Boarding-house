import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/models/property.dart';
import 'package:boardmate/models/room.dart';
import 'package:boardmate/models/school.dart';
import 'package:boardmate/screens/tenant/home_logic.dart';
import 'package:boardmate/screens/tenant/map_screen.dart';
import 'package:boardmate/screens/tenant/room_sheet.dart';
import 'package:boardmate/services/landlord_service.dart';
import 'package:boardmate/widgets/cost_card.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Property place(String id, String name, double lat, {List<String> tags = const [], int priceMin = 3000}) => Property(
    id: id,
    landlordId: 'l1',
    name: name,
    latitude: lat,
    longitude: 118.7338,
    priceMin: priceMin,
    priceMax: 6000,
    tags: tags,
  );

  Room room(String house, int price, {bool open = true}) =>
      Room(propertyId: house, landlordId: 'l1', name: 'R', type: RoomType.solo, monthlyPrice: price, available: open);

  final places = [
    place('a', 'Girls Wifi House', 9.7790, tags: ['Girls only', 'Wi-Fi']),
    place('b', 'Cheap Full House', 9.7768, priceMin: 1500),
    place('c', 'Boys House', 9.7746, tags: ['Boys only']),
  ];
  final rooms = roomsByHouse([room('a', 3500), room('b', 1500, open: false), room('c', 5000)]);

  test('Filters: open only, max price, and tags (all must match, any case)', () {
    List<String> names(HomeFilters f) => [for (final p in applyFilters(places, rooms, f)) p.name];
    expect(names(const HomeFilters()), hasLength(3));
    expect(names(const HomeFilters(openOnly: true)), ['Girls Wifi House', 'Boys House']);
    expect(names(const HomeFilters(maxPrice: 4000)), ['Girls Wifi House', 'Cheap Full House']);
    expect(names(const HomeFilters(tags: {'girls only', 'wi-fi'})), ['Girls Wifi House']);
    expect(const HomeFilters(openOnly: true, maxPrice: 4000, tags: {'Wi-Fi'}).count, 3);
  });

  test('Room sheet cost lines add up to the "About" price', () {
    const r = Room(
      propertyId: 'p',
      landlordId: 'l',
      name: 'Room 2',
      type: RoomType.solo,
      monthlyPrice: 4500,
      electricity: ElectricityCost.ownMeter,
      electricityEstimate: 600,
      wifi: WifiCost.paid,
      wifiPrice: 150,
    );
    final lines = roomCostLines(r);
    expect(CostCard.totalOf(lines), r.estimatedMonthly);
    expect(CostCard.totalOf(lines), 5250); // like the mockup
    expect(lines.map((l) => l.label), ['Rent', 'Electricity · own meter', 'Water', 'Wi-Fi']);
    expect(lines[2].note, 'included');
  });

  testWidgets('Map: price pins, tap one for the preview card, chips filter, List returns the filters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    HomeFilters? returned;
    await tester.pumpWidget(
      CupertinoApp(
        home: Builder(
          builder: (context) => CupertinoButton(
            child: const Text('open map'),
            onPressed: () async {
              returned = await Navigator.push<HomeFilters>(
                context,
                CupertinoPageRoute(
                  builder: (_) => MapScreen(
                    userId: 'u1',
                    school: schoolById('psu'),
                    filters: const HomeFilters(),
                    properties: Stream.value(places),
                    rooms: Stream.value([room('a', 3500), room('b', 1500, open: false), room('c', 5000)]),
                    landlords: Stream.value(const <String, LandlordInfo>{}),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('open map'));
    await tester.pumpAndSettle();

    expect(find.text('₱3,500'), findsOneWidget);
    expect(find.text('Full'), findsOneWidget);
    expect(find.text('Near PSU'), findsOneWidget);

    await tester.tap(find.text('₱3,500'));
    await tester.pump();
    expect(find.text('Girls Wifi House'), findsOneWidget);

    await tester.tap(find.text('Open rooms only'));
    await tester.pump();
    expect(find.text('Full'), findsNothing);

    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(returned?.openOnly, isTrue);
  });
}
