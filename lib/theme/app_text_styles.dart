import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles from DESIGN.md: Bricolage Grotesque for headings, Inter for everything else.
abstract final class AppText {
  static TextStyle _heading(double size, double spacing) => GoogleFonts.bricolageGrotesque(
    fontSize: size,
    fontWeight: FontWeight.w800,
    letterSpacing: spacing,
    height: 1.05,
    color: AppColors.ink,
  );

  /// "Rooms near your campus." (38) and page titles.
  static TextStyle get largeTitle => _heading(34, -1);

  static TextStyle get title => _heading(26, -0.6);

  /// "Room Map", "Real monthly cost".
  static TextStyle get section => _heading(18, -0.2);

  /// House name on a card.
  static TextStyle get cardTitle => _heading(20, -0.3);

  static TextStyle get body => GoogleFonts.inter(fontSize: 16, color: AppColors.ink);

  static TextStyle get secondary => GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get label => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink);

  static TextStyle get small => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink);

  /// Prices like "₱3,500".
  static TextStyle get price => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink);
}
