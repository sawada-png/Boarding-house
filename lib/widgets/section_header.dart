import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Section title with an optional teal link on the right, like "Rooms   + Add room".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: AppText.title)),
        if (actionLabel != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.lagoon),
            ),
          ),
      ],
    );
  }
}
