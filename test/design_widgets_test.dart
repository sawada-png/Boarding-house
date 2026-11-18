import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/widgets/cost_card.dart';
import 'package:boardmate/widgets/freshness_badge.dart';
import 'package:boardmate/widgets/room_map.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget wrap(Widget child) => CupertinoApp(home: Center(child: SizedBox(width: 600, child: child)));

  testWidgets('RoomMap: floors in order, open rooms tappable, taken and shared are not', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(wrap(RoomMap(
      floors: const [
        RoomMapFloor(label: '2F', tiles: [
          RoomMapTile(id: 'r3', label: 'Room 3'),
          RoomMapTile(id: 'r4', label: 'Room 4', open: true, price: '₱3,500', detail: 'bedspace · 2'),
        ]),
        RoomMapFloor(label: 'GF', tiles: [
          RoomMapTile(id: 'r2', label: 'Room 2', open: true, price: '₱4,500'),
          RoomMapTile.shared(id: 's', detail: 'Kitchen · CR'),
        ]),
      ],
      selectedId: 'r2',
      onTap: (t) => tapped.add(t.id),
      hint: 'Tap an open room',
    )));

    expect(find.text('Room Map'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget); // legend
    expect(tester.getTopLeft(find.text('2F')).dy, lessThan(tester.getTopLeft(find.text('GF')).dy));
    expect(find.text('₱3,500'), findsOneWidget);

    await tester.tap(find.text('Room 4'));
    await tester.tap(find.text('Room 3'));
    await tester.tap(find.text('Shared'));
    expect(tapped, ['r4', 'r3']); // taken rooms can be tapped (landlord switches them); shared can't
  });

  testWidgets('RoomMap wraps a floor with more than 3 rooms onto a second row', (tester) async {
    await tester.pumpWidget(wrap(RoomMap(floors: [
      RoomMapFloor(label: 'GF', tiles: [for (var i = 1; i <= 4; i++) RoomMapTile(id: '$i', label: 'Room $i')]),
    ])));
    expect(find.text('GF'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Room 4')).dy, greaterThan(tester.getTopLeft(find.text('Room 1')).dy));
  });

  testWidgets('CostCard adds up the lines, skips included ones, shows move-in', (tester) async {
    const lines = [
      CostLine('Rent', 4500),
      CostLine('Electricity · own meter', 600, estimate: true),
      CostLine.included('Water'),
      CostLine('Wi-Fi · shared', 150),
    ];
    expect(CostCard.totalOf(lines), 5250);

    await tester.pumpWidget(wrap(const CostCard(lines: lines, moveIn: '1 month deposit + 1 month advance')));
    expect(find.text('~₱600'), findsOneWidget);
    expect(find.text('included'), findsOneWidget);
    expect(find.text('₱5,250 /mo'), findsOneWidget);
    expect(find.text('Move-in: 1 month deposit + 1 month advance'), findsOneWidget);
  });

  test('Freshness text', () {
    expect(agoText(0), 'today');
    expect(agoText(2), '2d ago');
    expect(agoText(15), '2w ago');
    expect(agoText(70), '2mo ago');
  });
}
