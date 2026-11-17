import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/screens/tenant/tenant_shell.dart';
import 'package:boardmate/widgets/room_tabs.dart';

void main() {
  // Tests run offline, so don't download the Inter font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app() => const CupertinoApp(home: TenantShell());

  testWidgets('Home shows the title, a listing and the tab bar', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('Find your room'), findsOneWidget);
    expect(find.text("Nathan's Boarding House"), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
  });

  testWidgets('Tapping a room tab selects it', (tester) async {
    // Tall screen so the room tabs are not hidden behind the tab bar.
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await tester.tap(find.descendant(of: find.byType(RoomTabs), matching: find.text('Room 3')));
    await tester.pump();
    expect(find.text('Taken'), findsOneWidget);
  });
}
