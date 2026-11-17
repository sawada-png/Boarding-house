import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Gray bar of room tabs ("Room 1", "Room 2"...). Taken rooms show in gray text.
class RoomTabs extends StatelessWidget {
  const RoomTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.taken = const {},
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Indexes of rooms that are taken.
  final Set<int> taken;

  @override
  Widget build(BuildContext context) {
    // Up to 4 tabs fill the width like the mockup; more tabs scroll sideways.
    final fits = labels.length <= 4;
    final tabs = [
      for (var i = 0; i < labels.length; i++)
        fits ? Expanded(child: _tab(i)) : SizedBox(width: 84, child: _tab(i)),
    ];

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.segmentFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: fits
          ? Row(children: tabs)
          : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: tabs)),
    );
  }

  Widget _tab(int i) {
    final selected = i == selectedIndex;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 1)),
                  ],
                )
              : null,
          child: Text(
            labels[i],
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: taken.contains(i) ? AppColors.textSecondary : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
