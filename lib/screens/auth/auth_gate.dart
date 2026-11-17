import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../tenant/tenant_shell.dart';
import 'welcome_screen.dart';

/// Shows the welcome screen when logged out, and the app when logged in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(child: Center(child: CupertinoActivityIndicator()));
        }
        // Step 4 adds the "Student or Landlord?" check here.
        return snapshot.data == null ? const WelcomeScreen() : const TenantShell();
      },
    );
  }
}
