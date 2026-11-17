import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BoardMateApp());
}

class BoardMateApp extends StatelessWidget {
  const BoardMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'BoardMate',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF0B7285),
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
      ),
      home: StartPage(),
    );
  }
}

/// Temporary page for Step 1. Replaced by the login screen in Step 3.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BoardMate',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C1C1E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Find your room near campus',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B6B70)),
            ),
          ],
        ),
      ),
    );
  }
}
