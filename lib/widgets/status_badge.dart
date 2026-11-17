import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Small rounded label: teal for "Available", gray for "Taken".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.muted = false});

  /// Shortcut for a room's available/taken badge.
  const StatusBadge.room({super.key, required bool available})
      : label = available ? 'Available' : 'Taken',
        muted = !available;

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: muted ? AppColors.takenFill : AppColors.tealLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: muted ? AppColors.takenText : AppColors.tealDark,
        ),
      ),
    );
  }
}
