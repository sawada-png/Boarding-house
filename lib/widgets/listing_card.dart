import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'photo_box.dart';
import 'rounded_card.dart';
import 'status_badge.dart';

/// Boarding house card on the home list: photo, name, rating, distance, price.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.priceText,
    this.roomsAvailable,
    this.photoUrl,
    this.rating,
    this.reviewCount = 0,
    this.onTap,
  });

  final String name;

  /// For example "450 m from PSU · Tiniguiban".
  final String subtitle;

  /// For example "₱3,000–4,500".
  final String priceText;
  /// Null hides the rooms badge (for example before any rooms are added).
  final int? roomsAvailable;
  final String? photoUrl;

  /// Null when the place has no reviews yet.
  final double? rating;
  final int reviewCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RoundedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhotoBox(imageUrl: photoUrl, hint: 'Photo · front of the house', height: 170),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: AppText.cardTitle, overflow: TextOverflow.ellipsis),
                      ),
                      if (rating != null) _Rating(rating: rating!, count: reviewCount),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppText.secondary),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: priceText,
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                            children: [TextSpan(text: ' / month', style: AppText.secondary)],
                          ),
                        ),
                      ),
                      if (roomsAvailable case final n?)
                        StatusBadge(
                          label: n == 0 ? 'Full' : '$n room${n == 1 ? '' : 's'} available',
                          muted: n == 0,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(CupertinoIcons.star_fill, size: 14, color: AppColors.star),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: AppText.label),
        Text(' ($count)', style: AppText.secondary),
      ],
    );
  }
}
