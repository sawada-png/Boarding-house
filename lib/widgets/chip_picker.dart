import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'tag_chip.dart';

/// Tap chips to pick several items, plus a box to type your own.
/// Used for boarding house tags and for what's included in a room.
class ChipPicker extends StatefulWidget {
  const ChipPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.customPlaceholder = 'Add your own',
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final String customPlaceholder;

  @override
  State<ChipPicker> createState() => _ChipPickerState();
}

class _ChipPickerState extends State<ChipPicker> {
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _toggle(String item) {
    final next = [...widget.selected];
    next.contains(item) ? next.remove(item) : next.add(item);
    widget.onChanged(next);
  }

  void _addCustom() {
    final item = _custom.text.trim();
    if (item.isEmpty) return;
    if (!widget.selected.contains(item)) widget.onChanged([...widget.selected, item]);
    _custom.clear();
  }

  @override
  Widget build(BuildContext context) {
    final choices = [
      ...widget.options,
      ...widget.selected.where((s) => !widget.options.contains(s)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in choices)
              TagChip(
                label: item,
                selected: widget.selected.contains(item),
                onTap: () => _toggle(item),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _custom,
                placeholder: widget.customPlaceholder,
                style: AppText.body,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                onSubmitted: (_) => _addCustom(),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.only(left: 8),
              onPressed: _addCustom,
              child: Semantics(
                label: 'Add',
                child: const Icon(CupertinoIcons.add_circled_solid, size: 32, color: AppColors.teal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
