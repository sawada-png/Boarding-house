import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Pill-shaped tag like "Wi-Fi" or "Girls only". Black when selected.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.text : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: selected ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.card : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
