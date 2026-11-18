import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Map pin: white pill "₱3,500" with a lagoon bubble of open rooms.
/// Selected = ink and bigger. No open rooms = gray "Full".
class PricePin extends StatelessWidget {
  const PricePin({super.key, required this.price, required this.openRooms, this.selected = false, this.onTap});

  /// "₱3,500"
  final String price;
  final int openRooms;
  final bool selected;
  final VoidCallback? onTap;

  bool get full => openRooms == 0;

  @override
  Widget build(BuildContext context) {
    final Widget pill;
    if (full && !selected) {
      pill = Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.segmentFill, borderRadius: BorderRadius.circular(15)),
        child: Text('Full', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.takenText)),
      );
    } else {
      final h = selected ? 40.0 : 34.0;
      pill = Container(
        height: h,
        padding: EdgeInsets.only(left: selected ? 14 : 12, right: selected ? 6 : 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.card,
          borderRadius: BorderRadius.circular(h / 2),
          boxShadow: [
            BoxShadow(
              color: Color(selected ? 0x4D0F1D20 : 0x290F1D20),
              blurRadius: selected ? 20 : 14,
              offset: Offset(0, selected ? 8 : 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: selected ? 15 : 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.card : AppColors.ink,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              constraints: BoxConstraints(minWidth: selected ? 24 : 22),
              height: selected ? 24 : 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.lagoon : AppColors.lagoonLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$openRooms',
                style: GoogleFonts.inter(
                  fontSize: selected ? 12 : 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.card : AppColors.lagoonDark,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: full ? 'Full' : '$price, $openRooms rooms open',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: pill),
    );
  }
}
