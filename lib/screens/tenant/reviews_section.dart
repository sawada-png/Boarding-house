import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/chat.dart' show monthDay;
import '../../models/review.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/rounded_card.dart';

/// White pill on the house page: "★ 4.5 · 3 reviews", or "New · no reviews yet".
class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final avg = averageStars(reviews);
    final n = reviews.length;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avg != null) ...[
            const Icon(CupertinoIcons.star_fill, size: 13, color: AppColors.star),
            const SizedBox(width: 4),
          ],
          Text(
            avg == null ? 'New · no reviews yet' : '$avg · $n ${n == 1 ? 'review' : 'reviews'}',
            style: AppText.small.copyWith(color: avg == null ? AppColors.textSecondary : AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// "Reviews" list on the house page. Hidden when there are none (the chip already says "New").
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Reviews', style: AppText.section),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Only from students who lived here.', style: AppText.secondary.copyWith(fontSize: 13)),
          ),
          const SizedBox(height: 10),
          for (final r in reviews) ...[_ReviewCard(review: r), const SizedBox(height: 8)],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final r = review;
    return RoundedCard(
      shadow: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stars(count: r.stars, size: 15),
              const Spacer(),
              if (r.createdAt != null) Text(monthDay(r.createdAt!), style: AppText.small),
            ],
          ),
          if (r.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.text, style: AppText.body.copyWith(fontSize: 15, height: 1.4)),
          ],
          const SizedBox(height: 8),
          Text(
            '${r.firstName.isEmpty ? 'Student' : r.firstName} · stayed in ${r.roomName}',
            style: AppText.secondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Five stars, the first [count] filled. Tappable when [onTap] is set (the review form).
class Stars extends StatelessWidget {
  const Stars({super.key, required this.count, this.size = 16, this.onTap});

  final int count;
  final double size;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count out of 5 stars',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            onTap == null
                ? Icon(
                    i <= count ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    size: size,
                    color: i <= count ? AppColors.star : AppColors.border,
                  )
                : Semantics(
                    button: true,
                    label: '$i stars',
                    excludeSemantics: true,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 44),
                      onPressed: () => onTap!(i),
                      child: Icon(
                        i <= count ? CupertinoIcons.star_fill : CupertinoIcons.star,
                        size: size,
                        color: i <= count ? AppColors.star : AppColors.border,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
