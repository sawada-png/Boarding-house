import 'package:cupertino_ui/cupertino_ui.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../shared/dialogs.dart';
import 'phone_screen.dart';

/// First screen when logged out: pick phone, Google or Facebook.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = AuthService();

  /// Which button is spinning: 'google', 'facebook' or null.
  String? _busy;

  Future<void> _run(String which, Future<void> Function() signIn) async {
    setState(() => _busy = which);
    try {
      await signIn();
      // Logged in: the app switches screens by itself (see AuthGate).
    } catch (e) {
      final message = authErrorMessage(e);
      if (message != null && mounted) await showError(context, message);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lagoon,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(CupertinoIcons.house_fill, color: AppColors.card, size: 32),
              ),
              const SizedBox(height: 20),
              Text('BoardMate', style: AppText.largeTitle),
              const SizedBox(height: 8),
              Text(
                'Find a boarding house near campus in Puerto Princesa.',
                style: AppText.body.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue with phone',
                icon: CupertinoIcons.phone,
                onPressed: _busy != null
                    ? null
                    : () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (_) => const PhoneScreen()),
                        ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continue with Google',
                secondary: true,
                loading: _busy == 'google',
                onPressed: _busy != null ? null : () => _run('google', _auth.signInWithGoogle),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Continue with Facebook',
                secondary: true,
                loading: _busy == 'facebook',
                onPressed:
                    _busy != null ? null : () => _run('facebook', _auth.signInWithFacebook),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
