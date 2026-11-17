import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../shared/show_error.dart';

/// For now: who is logged in, switch mode, and log out. Full profile comes in Week 3.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.profile});

  final AppUser profile;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _switching = false;

  Future<void> _switchMode() async {
    final next = widget.profile.isLandlord ? UserRole.student : UserRole.landlord;
    setState(() => _switching = true);
    try {
      // AuthGate sees the change and swaps the whole screen.
      await UserService().setRole(widget.profile.uid, next);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't switch. Check your internet and try again.");
      if (mounted) setState(() => _switching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final contact = p.phone ?? p.email ?? '';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: AppText.largeTitle),
              const SizedBox(height: 8),
              Text(
                '${p.isLandlord ? 'Landlord' : 'Student'}${contact.isEmpty ? '' : ' · $contact'}',
                style: AppText.secondary,
              ),
              const Spacer(),
              PrimaryButton(
                label: p.isLandlord ? 'Switch to Student mode' : 'Switch to Landlord mode',
                loading: _switching,
                onPressed: _switchMode,
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Log out', secondary: true, onPressed: AuthService().signOut),
              const SizedBox(height: 90), // keep above the tab bar
            ],
          ),
        ),
      ),
    );
  }
}
