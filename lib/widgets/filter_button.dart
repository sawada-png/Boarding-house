import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// White sliders button (Home and Map). Turns ink with a small number when filters are on.
class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.count, required this.onTap, this.radius = 16, this.size = 48});

  /// How many filters are on. 0 = plain white button.
  final int count;
  final VoidCallback onTap;
  final double radius;
  final double size;

  @override
  Widget build(BuildContext context) {
    final on = count > 0;
    return Semantics(
      button: true,
      label: on ? 'Filters, $count on' : 'Filters',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: on ? AppColors.ink : AppColors.card,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: const [BoxShadow(color: Color(0x1A0F1D20), blurRadius: 18, offset: Offset(0, 6))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(CupertinoIcons.slider_horizontal_3, size: 20, color: on ? AppColors.card : AppColors.ink),
              if (on)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.lagoon, shape: BoxShape.circle),
                    child: Text(
                      '$count',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.card),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
