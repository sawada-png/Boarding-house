import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dashed_line.dart';
import 'freshness_badge.dart';
import 'heart_button.dart';
import 'photo_box.dart';
import 'room_dots.dart';
import 'walk_pill.dart';

/// Boarding house card on Home and Saved (design-2.0/2b): inset cover photo with a walk pill,
/// name, "New · Mandaragat", "from ₱3,000", then room dots and when rooms were checked.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.fromPrice,
    this.photoUrl,
    this.walkText,
    this.openRooms = 0,
    this.totalRooms = 0,
    this.checkedAt,
    this.saved,
    this.onSave,
    this.onTap,
  });

  final String name;

  /// "New · Mandaragat"
  final String subtitle;

  /// "₱3,000"
  final String fromPrice;
  final String? photoUrl;

  /// "6 min walk to PSU". Null hides the pill.
  final String? walkText;
  final int openRooms;
  final int totalRooms;
  final DateTime? checkedAt;

  /// Null hides the heart (landlord preview).
  final bool? saved;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final full = totalRooms > 0 && openRooms == 0;
    return Semantics(
      container: true,
      button: onTap != null,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x0A0F1D20), blurRadius: 2, offset: Offset(0, 1)),
              BoxShadow(color: Color(0x140F1D20), blurRadius: 32, offset: Offset(0, 12)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 188,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PhotoBox(imageUrl: photoUrl, hint: 'Cover photo', radius: 22),
                    if (walkText != null) Positioned(top: 12, left: 12, child: WalkPill(text: walkText!)),
                    if (saved != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: HeartButton(saved: saved!, onTap: onSave ?? () {}, size: 40),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppText.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(subtitle, style: AppText.secondary.copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('from', style: AppText.secondary.copyWith(fontSize: 12)),
                            Text(fromPrice, style: AppText.price),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const DashedLine(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (totalRooms == 0)
                          Expanded(child: Text('No rooms listed yet', style: AppText.secondary.copyWith(fontSize: 13)))
                        else ...[
                          RoomDots(open: openRooms, total: totalRooms, showLabel: false),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              full ? 'Full' : '$openRooms of $totalRooms open',
                              style: AppText.label.copyWith(
                                fontSize: 13,
                                color: full ? AppColors.textSecondary : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                        FreshnessBadge(checkedAt: checkedAt, prefix: ''),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
