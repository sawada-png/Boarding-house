import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One small square per room (lagoon = open, gray = taken) + "2 of 5 rooms open".
class RoomDots extends StatelessWidget {
  const RoomDots({super.key, required this.open, required this.total, this.showLabel = true, this.size = 18});

  final int open;
  final int total;
  final bool showLabel;
  final double size;

  // Past this, the squares would not fit on a card; the label still has the real numbers.
  static const _maxDots = 8;

  @override
  Widget build(BuildContext context) {
    final label = total == 0 ? 'No rooms listed yet' : '$open of $total rooms open';
    final dots = total.clamp(0, _maxDots);
    final openDots = total == 0 ? 0 : (open * dots / total).ceil();
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < dots; i++)
            Container(
              width: size,
              height: size,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i < openDots ? AppColors.lagoon : AppColors.segmentFill,
                borderRadius: BorderRadius.circular(size * 0.28),
              ),
            ),
          if (showLabel) ...[
            if (dots > 0) const SizedBox(width: 2),
            Flexible(child: Text(label, style: AppText.label.copyWith(fontSize: 13))),
          ],
        ],
      ),
    );
  }
}
