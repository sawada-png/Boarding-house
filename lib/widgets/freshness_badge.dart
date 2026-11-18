import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Green dot + "Rooms checked 2d ago": how recently the landlord confirmed the rooms.
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({
    super.key,
    required this.checkedAt,
    this.prefix = 'Rooms checked',
    this.pill = false,
    this.now,
  });

  /// Null when the landlord never confirmed.
  final DateTime? checkedAt;

  /// Words before the time: "Rooms checked 2d ago", "Checked 2d ago", or empty for just "2d ago".
  final String prefix;

  /// White pill around it (house page trust chips).
  final bool pill;

  /// Only set in tests.
  final DateTime? now;

  /// After this many days the dot turns orange: the listing may be out of date.
  static const staleAfterDays = 14;

  @override
  Widget build(BuildContext context) {
    final at = checkedAt;
    final days = at == null ? null : (now ?? DateTime.now()).difference(at).inDays;
    final fresh = days != null && days <= staleAfterDays;
    final text = at == null
        ? 'Not checked yet'
        : prefix.isEmpty
        ? agoText(days!)
        : '$prefix ${agoText(days!)}';

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: fresh ? AppColors.lagoon : AppColors.orange, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: pill ? AppText.small : AppText.secondary.copyWith(fontSize: 12)),
      ],
    );
    if (!pill) return row;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
      child: row,
    );
  }
}

/// 0 → "today", 2 → "2d ago", 15 → "2w ago", 70 → "2mo ago".
String agoText(int days) {
  if (days <= 0) return 'today';
  if (days < 14) return '${days}d ago';
  if (days < 60) return '${days ~/ 7}w ago';
  return '${days ~/ 30}mo ago';
}
