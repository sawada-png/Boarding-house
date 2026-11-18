import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/property.dart' show formatPesos;
import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/room_map.dart';
import '../../widgets/status_badge.dart';
import '../shared/dialogs.dart';

/// Turns rooms into Room Map floors: top floor first, only floors that have rooms.
List<RoomMapFloor> roomMapFloors(List<Room> rooms) {
  return [
    for (final floor in RoomFloor.values.reversed)
      if (rooms.any((r) => r.floor == floor))
        RoomMapFloor(
          label: floor.short,
          tiles: [
            for (final r in rooms.where((r) => r.floor == floor))
              RoomMapTile(
                id: r.id,
                label: r.name,
                open: r.available,
                price: '₱${formatPesos(r.monthlyPrice)}',
                detail: r.type == RoomType.solo
                    ? 'solo · ${r.privateCr ? 'own' : 'shared'} CR'
                    : 'bedspace · ${r.capacity}',
              ),
          ],
        ),
  ];
}

/// House page Room Map card. Tap a room to see its photos and price below the map.
/// With no rooms it shows empty dashed slots and an "Ask the owner" button (design-2.0/4b).
class HouseRoomsCard extends StatefulWidget {
  const HouseRoomsCard({super.key, required this.rooms});

  /// Already sorted Room 1, Room 2...
  final List<Room> rooms;

  @override
  State<HouseRoomsCard> createState() => _HouseRoomsCardState();
}

class _HouseRoomsCardState extends State<HouseRoomsCard> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final rooms = widget.rooms;
    if (rooms.isEmpty) return const _NoRooms();

    final open = rooms.where((r) => r.available).length;
    // Rooms can be deleted while the page is open, so fall back to the first open room.
    final selected =
        rooms.where((r) => r.id == _selectedId).firstOrNull ??
        rooms.where((r) => r.available).firstOrNull ??
        rooms.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoomMap(
          floors: roomMapFloors(rooms),
          selectedId: selected.id,
          onTap: (t) => setState(() => _selectedId = t.id),
          trailing: Text(
            '$open of ${rooms.length} open',
            style: AppText.label.copyWith(
              fontSize: 13,
              color: open == 0 ? AppColors.textSecondary : AppColors.lagoonDark,
            ),
          ),
          hint: 'Tap a room to see its photos and price.',
        ),
        const SizedBox(height: 12),
        _RoomDetails(room: selected),
      ],
    );
  }
}

class _NoRooms extends StatelessWidget {
  const _NoRooms();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Room Map', style: AppText.section),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.7,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        const Expanded(child: DashedBox()),
                      ],
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No rooms listed yet',
                        style: AppText.label.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text("The owner hasn't added rooms.", style: AppText.secondary.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () => showInfo(
              context,
              title: 'Coming soon',
              message: 'Chatting with landlords is coming in the next update.',
            ),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Text('Ask the owner which rooms are open', style: AppText.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photos, open/taken, type and price of the picked room.
class _RoomDetails extends StatelessWidget {
  const _RoomDetails({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final perPerson = room.type == RoomType.bedspace ? ' per person' : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 112,
            child: room.photos.isEmpty
                ? const PhotoBox(hint: 'Room photos', sand: true, width: 112, radius: 14)
                : ListView.separated(
                    // Key resets the scroll when another room is picked.
                    key: ValueKey(room.id),
                    scrollDirection: Axis.horizontal,
                    itemCount: room.photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => PhotoBox(imageUrl: room.photos[i], width: 112, radius: 14),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(child: Text(room.name, style: AppText.cardTitle)),
              const SizedBox(width: 8),
              StatusBadge.room(open: room.available),
            ],
          ),
          const SizedBox(height: 6),
          Text('${room.floor.label} · ${room.summary}', style: AppText.secondary.copyWith(height: 1.45)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: '₱${formatPesos(room.monthlyPrice)} ',
              style: AppText.price.copyWith(fontSize: 16),
              children: [TextSpan(text: '/ month$perPerson', style: AppText.secondary.copyWith(fontSize: 15))],
            ),
          ),
        ],
      ),
    );
  }
}
