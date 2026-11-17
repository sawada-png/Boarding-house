import 'package:cupertino_ui/cupertino_ui.dart';

import '../../services/auth_service.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// For now: shows who is logged in and a Log out button. Full profile comes in Week 3.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final who = user?.displayName ?? user?.phoneNumber ?? user?.email ?? '';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppText.largeTitle),
              const SizedBox(height: 8),
              Text('Logged in as $who', style: AppText.secondary),
              const Spacer(),
              PrimaryButton(label: 'Log out', secondary: true, onPressed: auth.signOut),
              const SizedBox(height: 90), // keep above the tab bar
            ],
          ),
        ),
      ),
    );
  }
}
