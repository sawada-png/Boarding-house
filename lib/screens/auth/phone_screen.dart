import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/primary_button.dart';
import '../shared/dialogs.dart';
import 'code_screen.dart';

/// Type your phone number, then we send an SMS code.
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _auth = AuthService();
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final phone = normalizePhPhone(_controller.text);
    if (phone == null) {
      await showError(context, 'Please type a PH mobile number, like 0912 345 6789.');
      return;
    }
    setState(() => _sending = true);
    try {
      final checkCode = await _auth.sendCode(phone);
      if (!mounted) return;
      await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => CodeScreen(phone: phone, checkCode: checkCode),
        ),
      );
    } catch (e) {
      final message = authErrorMessage(e);
      if (message != null && mounted) await showError(context, message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleBackButton(),
              const SizedBox(height: 20),
              Text('Your phone number', style: AppText.largeTitle.copyWith(fontSize: 30)),
              const SizedBox(height: 8),
              Text("We'll text you a 6-digit code.", style: AppText.secondary),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +\-]'))],
                placeholder: '0912 345 6789',
                style: AppText.body.copyWith(fontSize: 20),
                padding: const EdgeInsets.all(14),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text('🇵🇭', style: AppText.body.copyWith(fontSize: 20)),
                ),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                onSubmitted: (_) => _send(),
              ),
              const Spacer(),
              PrimaryButton(label: 'Send code', loading: _sending, onPressed: _send),
            ],
          ),
        ),
      ),
    );
  }
}
