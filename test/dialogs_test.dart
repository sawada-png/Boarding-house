import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:boardmate/screens/shared/dialogs.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<bool?> ask(WidgetTester tester, String tap) async {
    bool? answer;
    await tester.pumpWidget(CupertinoApp(
      home: Builder(
        builder: (context) => CupertinoButton(
          child: const Text('open'),
          onPressed: () async => answer = await showConfirmDelete(
            context,
            title: 'Delete Room 1?',
            message: "This can't be undone.",
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tap));
    await tester.pumpAndSettle();
    return answer;
  }

  testWidgets('Delete popup: Cancel says no, Delete says yes', (tester) async {
    expect(await ask(tester, 'Cancel'), isFalse);
    expect(await ask(tester, 'Delete'), isTrue);
  });
}
