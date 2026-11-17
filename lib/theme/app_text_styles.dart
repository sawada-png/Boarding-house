import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text sizes from the design/ mockups. All use the Inter font.
abstract final class AppText {
  static TextStyle get largeTitle => GoogleFonts.inter(
      fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: AppColors.text);

  static TextStyle get title => GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: AppColors.text);

  static TextStyle get section => GoogleFonts.inter(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text);

  static TextStyle get cardTitle => GoogleFonts.inter(
      fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text);

  static TextStyle get body => GoogleFonts.inter(fontSize: 16, color: AppColors.text);

  static TextStyle get secondary => GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary);

  static TextStyle get label => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text);

  static TextStyle get small => GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text);
}
