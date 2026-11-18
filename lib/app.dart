import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;

import 'screens/auth/auth_gate.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/web_phone_frame.dart';

class BoardMateApp extends StatelessWidget {
  const BoardMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'BoardMate',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _DragWithMouse(),
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.lagoon,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(textStyle: AppText.body),
      ),
      // In the browser, show the app inside a phone-sized frame. Phones are unaffected.
      builder: kIsWeb ? (context, child) => WebPhoneFrame(child: child) : null,
      home: const AuthGate(),
    );
  }
}

/// Lets a mouse drag lists and photo galleries in the browser, like a finger on a phone.
class _DragWithMouse extends CupertinoScrollBehavior {
  const _DragWithMouse();

  @override
  Set<PointerDeviceKind> get dragDevices => {...super.dragDevices, PointerDeviceKind.mouse};
}
