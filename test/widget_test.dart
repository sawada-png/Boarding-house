import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/app.dart';
import 'package:boardmate/widgets/room_tabs.dart';

void main() {
  // Tests run offline, so don't download the Inter font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Home shows the title, a listing and the tab bar', (tester) async {
    await tester.pumpWidget(const BoardMateApp());
    expect(find.text('Find your room'), findsOneWidget);
    expect(find.text("Nathan's Boarding House"), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
  });

  testWidgets('Tapping a room tab selects it', (tester) async {
    // Tall screen so the room tabs are not hidden behind the tab bar.
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const BoardMateApp());
    await tester.tap(find.descendant(of: find.byType(RoomTabs), matching: find.text('Room 3')));
    await tester.pump();
    expect(find.text('Taken'), findsOneWidget);
  });
}
