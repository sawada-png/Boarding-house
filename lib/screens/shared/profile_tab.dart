import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/status_badge.dart';
import '../landlord/get_verified_card.dart';
import '../shared/dialogs.dart';
import '../tenant/your_stays.dart';

/// Who is logged in, your stays (students) or the verified badge (landlords), switch mode, and log out.
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
    final initial = p.name.trim().isEmpty ? '?' : p.name.trim()[0].toUpperCase();

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
          children: [
            Text('Profile', style: AppText.largeTitle),
            const SizedBox(height: 20),
            RoundedCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.lagoonLight, shape: BoxShape.circle),
                    child: Text(initial, style: AppText.title.copyWith(color: AppColors.lagoonDark)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppText.cardTitle),
                        if (contact.isNotEmpty) ...[const SizedBox(height: 2), Text(contact, style: AppText.secondary)],
                        const SizedBox(height: 8),
                        StatusBadge(label: p.isLandlord ? 'Landlord mode' : 'Student'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (p.isLandlord) ...[
              const SizedBox(height: 16),
              GetVerifiedCard(uid: p.uid, name: p.name),
            ] else
              YourStays(uid: p.uid),
            const SizedBox(height: 16),
            RoundedCard(
              shadow: false,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(p.isLandlord ? 'Looking for a room?' : 'Do you own a boarding house?', style: AppText.section),
                  const SizedBox(height: 4),
                  Text(
                    p.isLandlord
                        ? 'Switch to Student mode to browse boarding houses.'
                        : 'Switch to Landlord mode to list it and its rooms for free.',
                    style: AppText.secondary,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: p.isLandlord ? 'Switch to Student mode' : 'Switch to Landlord mode',
                    icon: CupertinoIcons.arrow_2_squarepath,
                    loading: _switching,
                    onPressed: _switchMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Log out', secondary: true, onPressed: AuthService().signOut),
          ],
        ),
      ),
    );
  }
}
