import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Gray track with options; the picked one is an ink pill (school switcher, floor picker).
class SegmentedPills extends StatelessWidget {
  const SegmentedPills({super.key, required this.labels, required this.selected, required this.onChanged});

  final List<String> labels;

  /// Index of the picked option, or -1 for none.
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.segmentFill, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _option(i)),
          ],
        ],
      ),
    );
  }

  Widget _option(int i) {
    final on = i == selected;
    return Semantics(
      button: true,
      selected: on,
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.ink : const Color(0x00000000),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            labels[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on ? AppColors.card : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
