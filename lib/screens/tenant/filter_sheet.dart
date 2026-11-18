import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tag_chip.dart';
import 'home_logic.dart';

/// Max prices a student can pick (pesos a month).
const filterPrices = [2000, 3000, 4000, 5000];

/// Tags students filter by most (from BoardMate.md).
const filterTags = [
  'Girls only',
  'Boys only',
  'Wi-Fi',
  'No curfew',
  'Visitors allowed',
  'Water included',
  'Electric included',
  'Study area',
];

/// Bottom sheet to narrow the list. Returns the new filters, or null if closed.
Future<HomeFilters?> showFilterSheet(BuildContext context, HomeFilters current) {
  return showCupertinoModalPopup<HomeFilters>(
    context: context,
    builder: (_) => _FilterSheet(start: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.start});

  final HomeFilters start;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late HomeFilters _f = widget.start;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.stripeDark, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Text('Filters', style: AppText.title.copyWith(fontSize: 26))),
                CloseCircleButton(onTap: () => Navigator.pop(context), color: AppColors.card),
              ],
            ),
            const SizedBox(height: 18),
            Text('Price a month', style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TagChip(
                  label: 'Any price',
                  selected: _f.maxPrice == null,
                  onTap: () => setState(() => _f = _f.copyWith(maxPrice: () => null)),
                ),
                for (final p in filterPrices)
                  TagChip(
                    label: 'Under ₱${p ~/ 1000}k',
                    selected: _f.maxPrice == p,
                    onTap: () => setState(() => _f = _f.copyWith(maxPrice: () => p)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Must have', style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in filterTags)
                  TagChip(
                    label: t,
                    selected: _f.tags.contains(t),
                    onTap: () => setState(() {
                      final tags = {..._f.tags};
                      if (!tags.remove(t)) tags.add(t);
                      _f = _f.copyWith(tags: tags);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Expanded(child: Text('Only places with open rooms', style: AppText.label.copyWith(fontSize: 15))),
                  CupertinoSwitch(
                    value: _f.openOnly,
                    activeTrackColor: AppColors.lagoon,
                    onChanged: (v) => setState(() => _f = _f.copyWith(openOnly: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Clear',
                    secondary: true,
                    onPressed: () => setState(() => _f = const HomeFilters()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(label: 'Show places', onPressed: () => Navigator.pop(context, _f)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
