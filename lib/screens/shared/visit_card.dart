import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/chat.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// "VISIT · PICK A TIME" card in chat (design-2.0/6-chat).
/// The person who didn't send it picks one of the times and confirms, or says none work.
class VisitCard extends StatefulWidget {
  const VisitCard({
    super.key,
    required this.message,
    required this.mine,
    required this.otherName,
    required this.onAnswer,
    required this.onDirections,
  });

  final ChatMessage message;

  /// True if I sent it: then I wait for the other person.
  final bool mine;
  final String otherName;

  /// A picked time, or null for "None of these work".
  final Future<void> Function(String? picked) onAnswer;
  final VoidCallback onDirections;

  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> {
  String? _picked;
  bool _busy = false;

  Future<void> _answer(String? picked) async {
    setState(() => _busy = true);
    try {
      await widget.onAnswer(picked);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final status = m.visitStatus;
    final canPick = !widget.mine && status == VisitStatus.open && !_busy;
    final title = switch (status) {
      VisitStatus.open => widget.mine ? 'VISIT · WAITING FOR ${widget.otherName.toUpperCase()}' : 'VISIT · PICK A TIME',
      VisitStatus.confirmed => 'VISIT · CONFIRMED',
      VisitStatus.declined => 'VISIT · NO TIME WORKED',
    };
    final shown = status == VisitStatus.confirmed ? [m.picked!] : m.visitTimes;
    final selected = status == VisitStatus.confirmed ? m.picked : _picked;

    return Align(
      alignment: widget.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Color(0x140F1D20), blurRadius: 28, offset: Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: status == VisitStatus.declined ? AppColors.textSecondary : AppColors.lagoon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(longDay(m.visitDay!), style: AppText.section),
                  ],
                ),
              ),
              if (status != VisitStatus.declined)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: i < shown.length
                              ? _TimeChip(
                                  label: shown[i],
                                  selected: shown[i] == selected,
                                  onTap: canPick ? () => setState(() => _picked = shown[i]) : null,
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ],
                  ),
                ),
              if (canPick)
                CupertinoButton(
                  padding: const EdgeInsets.only(bottom: 10),
                  minimumSize: const Size(44, 32),
                  onPressed: () => _answer(null),
                  child: Text('None of these work', style: AppText.small.copyWith(color: AppColors.textSecondary)),
                ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FooterButton(label: 'Directions', color: AppColors.ink, onTap: widget.onDirections),
                    ),
                    if (canPick || (_busy && !widget.mine)) ...[
                      Container(width: 1, height: 46, color: AppColors.divider),
                      Expanded(
                        child: _FooterButton(
                          label: _picked == null ? 'Pick a time' : 'Confirm $_picked',
                          color: AppColors.lagoon,
                          onTap: _picked == null || _busy ? null : () => _answer(_picked),
                        ),
                      ),
                    ],
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

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.lagoon : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: selected ? null : Border.all(color: AppColors.border),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppText.label.copyWith(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.card : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 46),
      onPressed: onTap,
      child: Text(
        label,
        style: AppText.label.copyWith(fontSize: 14, color: onTap == null ? AppColors.textSecondary : color),
      ),
    );
  }
}
