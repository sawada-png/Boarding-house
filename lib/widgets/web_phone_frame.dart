import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

/// Browser preview only: shows the app phone-sized in a rounded frame on a dark background.
/// Browsers report no top safe area, so this adds [phoneTop] like a real phone's status bar area.
/// Every screen's SafeArea then leaves that space automatically.
class WebPhoneFrame extends StatelessWidget {
  const WebPhoneFrame({super.key, required this.child});

  final Widget? child;

  static const phoneTop = 48.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = math.max(media.padding.top, phoneTop);
    return ColoredBox(
      color: const Color(0xFF2C2C2E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 860),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF48484A), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(top: top),
                    viewPadding: media.viewPadding.copyWith(top: top),
                  ),
                  child: child ?? const SizedBox(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
