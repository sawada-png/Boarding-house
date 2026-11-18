import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../landlord/landlord_shell.dart';
import '../onboarding/choose_role_screen.dart';
import '../tenant/tenant_shell.dart';
import 'welcome_screen.dart';

/// Decides the first screen:
/// logged out → welcome, no profile yet → choose role, otherwise student or landlord mode.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, auth) {
        if (auth.connectionState == ConnectionState.waiting) return const _Loading();
        final user = auth.data;
        if (user == null) return const WelcomeScreen();

        return StreamBuilder<AppUser?>(
          key: ValueKey(user.uid),
          stream: UserService().watch(user.uid),
          builder: (context, profile) {
            if (profile.hasError) {
              return const _Loading(
                message: "Couldn't load your profile.\nCheck your internet, or log out and try again.",
                showLogout: true,
              );
            }
            if (profile.connectionState == ConnectionState.waiting) return const _Loading();
            final p = profile.data;
            if (p == null) return ChooseRoleScreen(user: user);
            return p.isLandlord
                ? LandlordShell(key: const ValueKey('landlord'), profile: p)
                : TenantShell(key: const ValueKey('student'), profile: p);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.message, this.showLogout = false});

  final String? message;
  final bool showLogout;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!showLogout) const CupertinoActivityIndicator(),
            if (message != null) Text(message!, textAlign: TextAlign.center),
            if (showLogout) CupertinoButton(onPressed: AuthService().signOut, child: const Text('Log out')),
          ],
        ),
      ),
    );
  }
}
