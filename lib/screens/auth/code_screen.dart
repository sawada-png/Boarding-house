import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/primary_button.dart';
import '../shared/show_error.dart';

/// Type the 6-digit SMS code.
class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key, required this.phone, required this.checkCode});

  final String phone;
  final CodeChecker checkCode;

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final _controller = TextEditingController();
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      await showError(context, 'The code has 6 digits.');
      return;
    }
    setState(() => _checking = true);
    try {
      await widget.checkCode(code);
      // Logged in: go back to the start; AuthGate now shows the app.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      final message = authErrorMessage(e);
      if (message != null && mounted) await showError(context, message);
    } finally {
      if (mounted) setState(() => _checking = false);
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
              Text('Enter the code', style: AppText.largeTitle.copyWith(fontSize: 30)),
              const SizedBox(height: 8),
              Text('Sent to ${widget.phone}', style: AppText.secondary),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofillHints: const [AutofillHints.oneTimeCode],
                placeholder: '123456',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(fontSize: 28, letterSpacing: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                onSubmitted: (_) => _check(),
              ),
              const Spacer(),
              PrimaryButton(label: 'Verify', loading: _checking, onPressed: _check),
            ],
          ),
        ),
      ),
    );
  }
}
