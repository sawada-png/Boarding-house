import 'package:cupertino_ui/cupertino_ui.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/striped_box.dart';
import '../../widgets/wordmark.dart';
import '../shared/dialogs.dart';
import 'phone_screen.dart';

/// First screen when logged out (design-2.0/1-welcome): Room Map picture, headline, phone or Google.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = AuthService();

  /// Which button is spinning: 'google' or null.
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: Wordmark()),
              const Expanded(child: Center(child: _RoomMapPicture())),
              Text(
                'See every open room before you go.',
                style: AppText.largeTitle.copyWith(fontSize: 40, letterSpacing: -1.3),
              ),
              const SizedBox(height: 10),
              Text(
                'Boarding houses near PSU, WPU and Holy Trinity in Puerto Princesa.',
                style: AppText.secondary.copyWith(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Continue with phone',
                icon: CupertinoIcons.device_phone_portrait,
                onPressed: _busy != null
                    ? null
                    : () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const PhoneScreen())),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Continue with Google',
                secondary: true,
                loading: _busy == 'google',
                onPressed: _busy != null ? null : () => _run('google', _auth.signInWithGoogle),
              ),
              // shortcut: Facebook login is hidden until its Meta developer app is set up.
              const SizedBox(height: 14),
              Text(
                'By continuing you agree to the Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppText.secondary.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiny house: roof line and 6 rooms (open green, taken striped, one picked with an orange ring).
class _RoomMapPicture extends StatelessWidget {
  const _RoomMapPicture();

  @override
  Widget build(BuildContext context) {
    Widget open({bool picked = false}) => DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.lagoon,
        borderRadius: BorderRadius.circular(14),
        boxShadow: picked
            ? const [
                BoxShadow(color: AppColors.orange, spreadRadius: 5),
                BoxShadow(color: AppColors.background, spreadRadius: 3),
              ]
            : null,
      ),
    );
    const taken = StripedBox(radius: 14);
    final tiles = [taken, open(), taken, open(picked: true), taken, const DashedBox(radius: 14)];

    return ExcludeSemantics(
      child: SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 250, height: 36, child: CustomPaint(painter: _Roof())),
            const SizedBox(height: 8),
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    for (var col = 0; col < 3; col++) ...[
                      if (col > 0) const SizedBox(width: 8),
                      Expanded(child: tiles[row * 3 + col]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Roof extends CustomPainter {
  const _Roof();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(2, size.height - 2)
        ..lineTo(size.width / 2, 2)
        ..lineTo(size.width - 2, size.height - 2),
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Roof old) => false;
}
