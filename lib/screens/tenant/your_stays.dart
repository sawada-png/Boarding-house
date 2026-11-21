import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/chat.dart' show monthDay;
import '../../models/review.dart';
import '../../models/stay.dart';
import '../../services/review_service.dart';
import '../../services/stay_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import '../shared/dialogs.dart';
import 'reviews_section.dart';

/// Student profile: confirm a move-in the landlord added, and review places you lived. Hidden with no stays.
class YourStays extends StatefulWidget {
  const YourStays({super.key, required this.uid, this.stays, this.reviews});

  final String uid;

  /// Only set in tests.
  final Stream<List<Stay>>? stays;
  final Stream<List<Review>>? reviews;

  @override
  State<YourStays> createState() => _YourStaysState();
}

class _YourStaysState extends State<YourStays> {
  late final _stays = widget.stays ?? StayService().watchForStudent(widget.uid);
  late final _reviews = widget.reviews ?? ReviewService().watchMine(widget.uid);

  Future<void> _answer(Stay stay, bool movedIn) async {
    try {
      await StayService().answer(stay, movedIn);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't save. Check your internet and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Stay>>(
      stream: _stays,
      builder: (context, stays) => StreamBuilder<List<Review>>(
        stream: _reviews,
        builder: (context, reviews) {
          final list = [
            for (final s in stays.data ?? const <Stay>[])
              if (s.status != StayStatus.declined) s,
          ];
          if (list.isEmpty) return const SizedBox();
          final reviewed = {for (final r in reviews.data ?? const <Review>[]) r.id: r};
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your stays', style: AppText.section),
                const SizedBox(height: 10),
                for (final s in list) ...[
                  _StayCard(
                    stay: s,
                    review: reviewed[s.id],
                    onAnswer: (movedIn) => _answer(s, movedIn),
                    onReview: () => showReviewSheet(context, s, reviewed[s.id]),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.stay, required this.review, required this.onAnswer, required this.onReview});

  final Stay stay;
  final Review? review;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final s = stay;
    final when = switch (s.status) {
      StayStatus.active => s.movedInAt == null ? 'Living here' : 'Living here since ${monthDay(s.movedInAt!)}',
      StayStatus.ended => ['Moved out', if (s.movedOutAt != null) monthDay(s.movedOutAt!)].join(' '),
      _ => '',
    };
    return RoundedCard(
      shadow: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${s.propertyName} · ${s.roomName}',
            style: AppText.label.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (s.status == StayStatus.pending) ...[
            Text(
              'The owner says you moved into ${s.roomName}. Confirm it to unlock reviews.',
              style: AppText.secondary.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(label: 'Not me', secondary: true, onPressed: () => onAnswer(false)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Yes, I moved in',
                    color: AppColors.lagoon,
                    onPressed: () => onAnswer(true),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(when, style: AppText.secondary),
            const SizedBox(height: 12),
            if (review != null) ...[Stars(count: review!.stars), const SizedBox(height: 8)],
            PrimaryButton(
              label: review == null ? 'Write a review' : 'Edit your review',
              secondary: review != null,
              icon: CupertinoIcons.star,
              onPressed: onReview,
            ),
          ],
        ],
      ),
    );
  }
}

/// Stars + a short text. Saves to reviews/{stayId}.
Future<void> showReviewSheet(BuildContext context, Stay stay, Review? existing) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => _ReviewSheet(stay: stay, existing: existing),
  );
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.stay, this.existing});

  final Stay stay;
  final Review? existing;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late int _stars = widget.existing?.stars ?? 0;
  late final _text = TextEditingController(text: widget.existing?.text);
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ReviewService().save(widget.stay, stars: _stars, text: _text.text);
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'Thanks for your review!');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        await showError(context, "Couldn't save your review. Check your internet and try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keeps the text field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Review ${widget.stay.propertyName}', style: AppText.title)),
                    CloseCircleButton(onTap: () => Navigator.pop(context), color: AppColors.background),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Other students read this before they visit.', style: AppText.secondary),
                const SizedBox(height: 12),
                Stars(count: _stars, size: 30, onTap: (n) => setState(() => _stars = n)),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _text,
                  placeholder: 'How was it? Water, noise, the owner, safety...',
                  maxLines: 4,
                  maxLength: reviewMaxLength,
                  padding: const EdgeInsets.all(14),
                  style: AppText.body.copyWith(fontSize: 15),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: _stars == 0 ? 'Tap the stars first' : 'Post review',
                  loading: _saving,
                  onPressed: _stars == 0 ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
