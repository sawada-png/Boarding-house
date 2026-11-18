import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Pill chip like "Wi-Fi" or "Under ₱4k". Ink when selected.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.selected = false, this.onTap, this.outlined = true});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// False for white chips without a border (on maps and gray backgrounds).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.card,
            borderRadius: BorderRadius.circular(17),
            border: selected || !outlined ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.card : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
