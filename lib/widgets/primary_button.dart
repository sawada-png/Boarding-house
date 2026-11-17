import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Big teal button, like "Message" in the mockup. Shows a spinner while [loading].
/// With [secondary] it's white with a gray border instead.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textColor = secondary ? AppColors.text : AppColors.card;
    return Container(
      height: 50,
      width: double.infinity,
      decoration: secondary
          ? BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            )
          : null,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: secondary ? null : AppColors.teal,
        borderRadius: BorderRadius.circular(14),
        onPressed: loading ? null : onPressed,
        child: loading
            ? CupertinoActivityIndicator(color: secondary ? AppColors.textSecondary : AppColors.card)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ],
              ),
      ),
    );
  }
}
