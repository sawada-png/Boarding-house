import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../shared/dialogs.dart';

/// Shown once after the first login: your name, and student or landlord.
class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key, required this.user});

  final User user;

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  late final _name = TextEditingController(text: widget.user.displayName ?? '');
  UserRole? _role;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return showError(context, 'Please type your name.');
    if (_role == null) return showError(context, 'Please pick student or landlord.');

    setState(() => _saving = true);
    try {
      await UserService().create(widget.user, name: name, role: _role!);
      // Saved: AuthGate sees the new profile and opens the right screen.
    } catch (_) {
      if (mounted) await showError(context, "Couldn't save. Check your internet and try again.");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            Text('Welcome!', style: AppText.largeTitle),
            const SizedBox(height: 8),
            Text('Tell us a bit about you.', style: AppText.secondary.copyWith(fontSize: 16)),
            const SizedBox(height: 28),
            Text('Your name', style: AppText.label),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _name,
              placeholder: 'Juan Dela Cruz',
              textCapitalization: TextCapitalization.words,
              style: AppText.body,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 28),
            Text('I am a...', style: AppText.label),
            const SizedBox(height: 8),
            _RoleCard(
              icon: CupertinoIcons.book,
              title: 'Student',
              subtitle: 'Find a room near campus',
              selected: _role == UserRole.student,
              onTap: () => setState(() => _role = UserRole.student),
            ),
            const SizedBox(height: 12),
            _RoleCard(
              icon: CupertinoIcons.house,
              title: 'Landlord',
              subtitle: 'List my boarding house and rooms',
              selected: _role == UserRole.landlord,
              onTap: () => setState(() => _role = UserRole.landlord),
            ),
            const SizedBox(height: 8),
            Text('You can switch later in Profile.', style: AppText.secondary.copyWith(fontSize: 13)),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Continue', loading: _saving, onPressed: _save),
            const SizedBox(height: 12),
            CupertinoButton(
              onPressed: AuthService().signOut,
              child: Text('Log out', style: AppText.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.lagoon : AppColors.card,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.lagoon : AppColors.lagoonLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: selected ? AppColors.card : AppColors.lagoon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.cardTitle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.secondary),
                  ],
                ),
              ),
              Icon(
                selected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                color: selected ? AppColors.lagoon : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
