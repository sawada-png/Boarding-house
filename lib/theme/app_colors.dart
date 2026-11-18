import 'package:cupertino_ui/cupertino_ui.dart';

/// All colors used in the app, from DESIGN.md (BoardMate 2.0).
abstract final class AppColors {
  /// Main text, main buttons and the tab bar.
  static const ink = Color(0xFF0F1D20);

  /// Open rooms, links, success.
  static const lagoon = Color(0xFF0B6E5F);
  static const lagoonDark = Color(0xFF08564A);
  static const lagoonLight = Color(0xFFDDEFEA);

  /// Tiny highlights only (selected room ring, dots). Never text on white.
  static const orange = Color(0xFFE8692E);
  static const warning = Color(0xFFB4501E);

  static const background = Color(0xFFF3F5F4);
  static const card = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF5B6664);
  static const border = Color(0xFFDCE2E0);
  static const divider = Color(0xFFDCE2E0);
  static const segmentFill = Color(0xFFE3E8E6);

  /// Taken rooms: diagonal stripes of these two grays.
  static const stripeDark = Color(0xFFD5DCD9);
  static const stripeLight = Color(0xFFEEF1F0);
  static const takenFill = Color(0xFFE3E8E6);
  static const takenText = Color(0xFF4A5553);

  static const star = Color(0xFFF5A524);
  static const error = Color(0xFFC23B32);
  static const errorLight = Color(0xFFFBEAE8);

  /// Text on the dark ink cards.
  static const onInk = Color(0xFFDCE4E2);
  static const onInkMuted = Color(0xFFA9B8B4);
  static const onInkGood = Color(0xFF7FD3C2);

  /// Live board (dark header card on Home).
  static const liveGreen = Color(0xFF2BA58F);
  static const inkRaised = Color(0xFF1F2E31);
  static const inkLine = Color(0xFF2C3A3D);
  static const onInkSoft = Color(0xFFC9D3D0);

  // Placeholder colors shown before a photo is uploaded.
  static const photoTeal = Color(0xFFCFE0DA);
  static const photoTealText = Color(0xFF3F5E56);
  static const photoSand = Color(0xFFE2DED3);
  static const photoSandText = Color(0xFF6E5E45);
}
