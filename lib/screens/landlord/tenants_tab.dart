import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/chat.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/stay.dart';
import '../../services/chat_service.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../services/stay_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import '../shared/dialogs.dart';
import 'add_tenant_sheet.dart';

/// Landlord: who lives here. Add a tenant (the student confirms) and mark them moved out.
class TenantsTab extends StatefulWidget {
  const TenantsTab({super.key, required this.profile});

  final AppUser profile;

  @override
  State<TenantsTab> createState() => _TenantsTabState();
}

class _TenantsTabState extends State<TenantsTab> {
  late final _properties = PropertyService().watchMine(widget.profile.uid);
  late final _stays = StayService().watchForLandlord(widget.profile.uid);
  late final _chats = ChatService().watchMine(widget.profile.uid);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Property>>(
          stream: _properties,
          builder: (context, props) {
            // shortcut: first boarding house only, like the dashboard.
            final property = (props.data?.isEmpty ?? true) ? null : props.data!.first;
            return StreamBuilder<List<Room>>(
              key: ValueKey(property?.id),
              stream: property == null ? null : RoomService().watchForProperty(property.id),
              builder: (context, rooms) => StreamBuilder<List<Stay>>(
                stream: _stays,
                builder: (context, stays) => StreamBuilder<List<Chat>>(
                  stream: _chats,
                  builder: (context, chats) => ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
                    children: [
                      Text(
                        'Landlord mode',
                        style: AppText.label.copyWith(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text('Tenants', style: AppText.largeTitle.copyWith(fontSize: 30, letterSpacing: -0.8)),
                      const SizedBox(height: 18),
                      ..._body(props, property, rooms.data, stays, chats.data),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _body(
    AsyncSnapshot<List<Property>> props,
    Property? property,
    List<Room>? rooms,
    AsyncSnapshot<List<Stay>> staysSnap,
    List<Chat>? chats,
  ) {
    if (props.hasError || staysSnap.hasError) {
      return [Text("Couldn't load your tenants. Check your internet.", style: AppText.secondary)];
    }
    if (!props.hasData || !staysSnap.hasData) {
      return [const Padding(padding: EdgeInsets.only(top: 40), child: CupertinoActivityIndicator())];
    }
    if (property == null) {
      return [Text('Add your boarding house first, on the House tab.', style: AppText.secondary)];
    }
    final stays = [
      for (final s in staysSnap.data!)
        if (s.propertyId == property.id) s,
    ];
    List<Stay> only(StayStatus status) => [
      for (final s in stays)
        if (s.status == status) s,
    ];
    final pending = only(StayStatus.pending);
    final active = only(StayStatus.active);
    final past = only(StayStatus.ended);

    return [
      PrimaryButton(
        label: 'Add tenant',
        icon: CupertinoIcons.person_add,
        onPressed: rooms == null || rooms.isEmpty ? null : () => _add(property, rooms, stays, chats ?? const []),
      ),
      if (rooms != null && rooms.isEmpty) ...[
        const SizedBox(height: 8),
        Text('Add rooms on the House tab first.', style: AppText.secondary),
      ],
      const SizedBox(height: 20),
      if (stays.where((s) => s.status != StayStatus.declined).isEmpty) const _Empty(),
      if (pending.isNotEmpty)
        _Section(
          title: 'Waiting for the student',
          stays: pending,
          detail: (s) => '${s.roomName} · they confirm in their app',
          action: ('Cancel', (s) => _moveOut(s, rooms, cancel: true)),
        ),
      if (active.isNotEmpty)
        _Section(
          title: 'Living here',
          stays: active,
          detail: (s) => '${s.roomName}${s.movedInAt == null ? '' : ' · since ${monthDay(s.movedInAt!)}'}',
          action: ('Moved out', (s) => _moveOut(s, rooms)),
        ),
      if (past.isNotEmpty)
        _Section(
          title: 'Past tenants',
          stays: past,
          detail: (s) => [
            s.roomName,
            if (s.movedInAt != null && s.movedOutAt != null) '${monthDay(s.movedInAt!)} – ${monthDay(s.movedOutAt!)}',
          ].join(' · '),
        ),
    ];
  }

  Future<void> _add(Property property, List<Room> rooms, List<Stay> stays, List<Chat> chats) async {
    final living = {
      for (final s in stays)
        if (s.holdsBed) s.studentId,
    };
    final students = [
      for (final c in chats)
        if (c.propertyId == property.id && c.landlordId == widget.profile.uid && !living.contains(c.studentId)) c,
    ];
    final picked = await showAddTenantSheet(context, students: students, rooms: rooms);
    if (picked == null || !mounted) return;
    final room = picked.room;
    final stay = Stay(
      studentId: picked.student.studentId,
      studentName: picked.student.studentName,
      landlordId: widget.profile.uid,
      propertyId: property.id,
      propertyName: property.name,
      roomId: room.id,
      roomName: room.name,
    );
    try {
      final full = fillsRoom(room, stays);
      await StayService().add(stay, room, fillsRoom: full);
      if (mounted) showToast(context, full ? 'Added · ${room.name} is now taken' : 'Added');
    } catch (_) {
      if (mounted) await showError(context, "Couldn't add the tenant. Check your internet and try again.");
    }
  }

  Future<void> _moveOut(Stay stay, List<Room>? rooms, {bool cancel = false}) async {
    final name = stay.studentName.isEmpty ? 'this student' : stay.studentName.split(' ').first;
    final ok = await showConfirmDelete(
      context,
      title: cancel ? 'Cancel for $name?' : '$name moved out?',
      message: '${stay.roomName} opens again for new students.',
      confirmLabel: cancel ? 'Cancel tenant' : 'Moved out',
    );
    if (!ok || !mounted) return;
    final room = rooms?.where((r) => r.id == stay.roomId).firstOrNull;
    try {
      await StayService().moveOut(stay, room);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't save. Check your internet and try again.");
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.stays, required this.detail, this.action});

  final String title;
  final List<Stay> stays;
  final String Function(Stay) detail;
  final (String, void Function(Stay))? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppText.section),
          const SizedBox(height: 10),
          RoundedCard(
            shadow: false,
            child: Column(
              children: [
                for (var i = 0; i < stays.length; i++) ...[
                  if (i > 0) Container(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stays[i].studentName.isEmpty ? 'Student' : stays[i].studentName,
                                style: AppText.label.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(detail(stays[i]), style: AppText.secondary.copyWith(fontSize: 13)),
                            ],
                          ),
                        ),
                        if (action != null)
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(44, 44),
                            onPressed: () => action!.$2(stays[i]),
                            child: Text(action!.$1, style: AppText.label.copyWith(color: AppColors.lagoon)),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      shadow: false,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No tenants yet', style: AppText.section),
          const SizedBox(height: 6),
          Text(
            'When a student moves in, add them here. They confirm in their app, the room switches to taken, '
            'and later they can leave a review.',
            style: AppText.secondary.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
