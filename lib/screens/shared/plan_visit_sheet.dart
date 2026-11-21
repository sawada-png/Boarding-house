import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/chat.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/primary_button.dart';

/// Pick a day and up to 3 times. Returns null if closed.
Future<({DateTime day, List<String> times})?> showPlanVisitSheet(BuildContext context, {DateTime? today}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (_) => _PlanVisitSheet(today: today ?? DateTime.now()),
  );
}

class _PlanVisitSheet extends StatefulWidget {
  const _PlanVisitSheet({required this.today});

  final DateTime today;

  @override
  State<_PlanVisitSheet> createState() => _PlanVisitSheetState();
}

class _PlanVisitSheetState extends State<_PlanVisitSheet> {
  static const maxTimes = 3;

  late final _days = [
    for (var i = 0; i < 7; i++) DateTime(widget.today.year, widget.today.month, widget.today.day + i),
  ];
  late DateTime _day = _days[1];
  final _times = <String>[];

  String _dayLabel(int i) => switch (i) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => shortDay(_days[i]).split(',').first,
  };

  void _toggle(String t) => setState(() {
    if (_times.remove(t)) return;
    if (_times.length < maxTimes) _times.add(t);
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Plan a visit', style: AppText.title)),
                  CloseCircleButton(onTap: () => Navigator.pop(context), color: AppColors.background),
                ],
              ),
              const SizedBox(height: 4),
              Text('Pick a day and up to 3 times. They choose one.', style: AppText.secondary),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < _days.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      _Pill(
                        label: _dayLabel(i),
                        caption: monthDay(_days[i]),
                        selected: _days[i] == _day,
                        onTap: () => setState(() => _day = _days[i]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in visitTimes) _Pill(label: t, selected: _times.contains(t), onTap: () => _toggle(t)),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _times.isEmpty
                    ? 'Pick at least 1 time'
                    : 'Send ${_times.length} ${_times.length == 1 ? 'time' : 'times'}',
                color: AppColors.lagoon,
                icon: CupertinoIcons.calendar,
                onPressed: _times.isEmpty
                    ? null
                    : () => Navigator.pop(context, (
                        day: _day,
                        // Keep them in clock order, not tap order.
                        times: [
                          for (final t in visitTimes)
                            if (_times.contains(t)) t,
                        ],
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.caption, required this.selected, required this.onTap});

  final String label;
  final String? caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.card : AppColors.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.lagoon : AppColors.background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppText.label.copyWith(fontSize: 14, color: color)),
              if (caption != null)
                Text(
                  caption!,
                  style: AppText.small.copyWith(color: selected ? AppColors.lagoonLight : AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
