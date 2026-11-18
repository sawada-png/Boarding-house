import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Big pill button. Ink by default, shows a spinner while [loading].
/// With [secondary] it's white with a gray border instead.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.icon,
    this.color = AppColors.ink,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;
  final IconData? icon;

  /// Fill of the main button: ink, lagoon for "Ask about Room 2", red for delete.
  final Color color;

  /// False to fit the text (bottom bars) instead of filling the width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final textColor = secondary ? AppColors.ink : AppColors.card;
    final shape = BorderRadius.circular(28);
    return Container(
      height: 54,
      width: expand ? double.infinity : null,
      decoration: secondary
          ? BoxDecoration(
              color: AppColors.card,
              borderRadius: shape,
              border: Border.all(color: AppColors.border),
            )
          : null,
      child: CupertinoButton(
        padding: expand ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 22),
        color: secondary ? null : color,
        disabledColor: secondary ? const Color(0x00000000) : color.withValues(alpha: 0.5),
        borderRadius: shape,
        onPressed: loading ? null : onPressed,
        child: loading
            ? CupertinoActivityIndicator(color: secondary ? AppColors.textSecondary : AppColors.card)
            : Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 19, color: textColor), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ],
              ),
      ),
    );
  }
}
