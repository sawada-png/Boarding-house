import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/chat.dart';
import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/primary_button.dart';

/// Pick who moved in (a student who messaged about this house) and which room.
Future<({Chat student, Room room})?> showAddTenantSheet(
  BuildContext context, {
  required List<Chat> students,
  required List<Room> rooms,
}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (_) => _AddTenantSheet(students: students, rooms: rooms),
  );
}

class _AddTenantSheet extends StatefulWidget {
  const _AddTenantSheet({required this.students, required this.rooms});

  final List<Chat> students;
  final List<Room> rooms;

  @override
  State<_AddTenantSheet> createState() => _AddTenantSheetState();
}

class _AddTenantSheetState extends State<_AddTenantSheet> {
  Chat? _student;
  Room? _room;

  @override
  Widget build(BuildContext context) {
    final ready = _student != null && _room != null;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
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
                    Expanded(child: Text('Add tenant', style: AppText.title)),
                    CloseCircleButton(onTap: () => Navigator.pop(context), color: AppColors.background),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'They confirm in their app. Then they can leave a review after living here.',
                  style: AppText.secondary.copyWith(height: 1.4),
                ),
                const SizedBox(height: 18),
                Text('Who moved in?', style: AppText.label),
                const SizedBox(height: 8),
                if (widget.students.isEmpty)
                  Text(
                    'Only students who messaged you about this house show up here. Ask them to send you a message first.',
                    style: AppText.secondary.copyWith(height: 1.4),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in widget.students)
                        _Choice(
                          label: c.otherName(c.landlordId),
                          selected: _student?.studentId == c.studentId,
                          onTap: () => setState(() => _student = c),
                        ),
                    ],
                  ),
                const SizedBox(height: 18),
                Text('Which room?', style: AppText.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final r in widget.rooms)
                      _Choice(
                        label: r.available ? r.name : '${r.name} · taken',
                        selected: _room?.id == r.id,
                        onTap: () => setState(() => _room = r),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Add tenant',
                  icon: CupertinoIcons.person_add,
                  onPressed: ready ? () => Navigator.pop(context, (student: _student!, room: _room!)) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.background,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(label, style: AppText.label.copyWith(color: selected ? AppColors.card : AppColors.ink)),
        ),
      ),
    );
  }
}
