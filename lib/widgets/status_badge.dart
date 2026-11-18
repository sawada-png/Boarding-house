import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Small pill label: lagoon for "Open", gray for "Taken".
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.muted = false});

  /// A room's open/taken badge.
  const StatusBadge.room({super.key, required bool open})
      : label = open ? 'Open' : 'Taken',
        muted = !open;

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: muted ? AppColors.takenFill : AppColors.lagoonLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: muted ? AppColors.takenText : AppColors.lagoonDark,
        ),
      ),
    );
  }
}
