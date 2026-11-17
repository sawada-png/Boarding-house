import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/main.dart';

void main() {
  testWidgets('Start page shows the app name', (tester) async {
    await tester.pumpWidget(const BoardMateApp());
    expect(find.text('BoardMate'), findsOneWidget);
  });
}
