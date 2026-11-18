import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// Round ✕ button to close a sheet or hide a card.
class CloseCircleButton extends StatelessWidget {
  const CloseCircleButton({super.key, required this.onTap, this.color = AppColors.card, this.label = 'Close'});

  final VoidCallback onTap;

  /// Circle fill. Use a gray on white cards, white on gray sheets.
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(CupertinoIcons.xmark, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}
