import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Big teal button, like "Message" in the mockup. Shows a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(14),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: AppColors.card)
            : Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.card),
              ),
      ),
    );
  }
}
