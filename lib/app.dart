import 'package:cupertino_ui/cupertino_ui.dart';

import 'screens/tenant/tenant_shell.dart';
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
      // Step 3 puts the login screen in front of this.
      home: const TenantShell(),
    );
  }
}
