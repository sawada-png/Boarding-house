import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/auth/auth_gate.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class BoardMateApp extends StatelessWidget {
  const BoardMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'BoardMate',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.teal,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(textStyle: AppText.body),
      ),
      // In the browser, show the app phone-sized in the middle. Phones are unaffected.
      builder: kIsWeb
          ? (context, child) => ColoredBox(
                color: const Color(0xFF2C2C2E),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: child,
                  ),
                ),
              )
          : null,
      home: const AuthGate(),
    );
  }
}
