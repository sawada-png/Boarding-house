import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// Shows a BoardMate-style popup card with an error message and a "Got it" button.
Future<void> showError(BuildContext context, String message, {String title = "Something's not right"}) {
  return _showCard<void>(
    context,
    icon: CupertinoIcons.exclamationmark,
    title: title,
    message: message,
    buttons: (close) => [PrimaryButton(label: 'Got it', onPressed: () => close(null))],
  );
}

/// Asks "Are you sure?" before something that can't be undone, like deleting.
/// Returns true only if the user taps the red button.
Future<bool> showConfirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final answer = await _showCard<bool>(
    context,
    icon: CupertinoIcons.trash,
    title: title,
    message: message,
    buttons: (close) => [
      PrimaryButton(label: confirmLabel, color: AppColors.error, onPressed: () => close(true)),
      const SizedBox(height: 10),
      PrimaryButton(label: 'Cancel', secondary: true, onPressed: () => close(false)),
    ],
  );
  return answer ?? false;
}

/// The white rounded popup card both dialogs use.
Future<T?> _showCard<T>(
  BuildContext context, {
  required IconData icon,
  Color iconColor = AppColors.error,
  Color iconFill = AppColors.errorLight,
  required String title,
  required String message,
  required List<Widget> Function(void Function(T?) close) buttons,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x730F1D20),
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
      );
    },
    pageBuilder: (context, _, _) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Color(0x290F1D20), blurRadius: 40, offset: Offset(0, 16))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: iconFill, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: AppText.cardTitle.copyWith(fontSize: 22)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: AppText.secondary.copyWith(fontSize: 15, height: 1.4)),
              const SizedBox(height: 24),
              ...buttons((value) => Navigator.pop(context, value)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A calm popup for news like "Coming soon". Lagoon icon instead of red.
Future<void> showInfo(BuildContext context, {required String title, required String message}) {
  return _showCard<void>(
    context,
    icon: CupertinoIcons.sparkles,
    iconColor: AppColors.lagoon,
    iconFill: AppColors.lagoonLight,
    title: title,
    message: message,
    buttons: (close) => [PrimaryButton(label: 'Got it', onPressed: () => close(null))],
  );
}

/// Small dark pill near the bottom that disappears by itself, like "Copied!".
void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 0,
      right: 0,
      bottom: 120,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 180),
            builder: (context, t, child) => Opacity(opacity: t, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(22)),
              child: Text(message, style: AppText.label.copyWith(color: AppColors.card)),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1600), entry.remove);
}
