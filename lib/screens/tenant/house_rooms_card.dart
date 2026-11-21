import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/property.dart' show formatPesos;
import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashed_box.dart';
import '../../widgets/room_map.dart';
import 'room_sheet.dart';

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
  const HouseRoomsCard({super.key, required this.rooms, required this.onAsk});

  /// Already sorted Room 1, Room 2...
  final List<Room> rooms;

  /// Opens the chat, about one room or (null) the whole house.
  final ValueChanged<Room?> onAsk;

  @override
  State<HouseRoomsCard> createState() => _HouseRoomsCardState();
}

class _HouseRoomsCardState extends State<HouseRoomsCard> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final rooms = widget.rooms;
    if (rooms.isEmpty) return _NoRooms(onAsk: () => widget.onAsk(null));

    final open = rooms.where((r) => r.available).length;

    return RoomMap(
      floors: roomMapFloors(rooms),
      selectedId: _selectedId,
      onTap: (t) {
        setState(() => _selectedId = t.id);
        showRoomSheet(context, rooms.firstWhere((r) => r.id == t.id), onAsk: widget.onAsk);
      },
      trailing: Text(
        '$open of ${rooms.length} open',
        style: AppText.label.copyWith(fontSize: 13, color: open == 0 ? AppColors.textSecondary : AppColors.lagoonDark),
      ),
      hint: 'Tap a room to see photos and the real monthly cost.',
    );
  }
}

class _NoRooms extends StatelessWidget {
  const _NoRooms({required this.onAsk});

  final VoidCallback onAsk;

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
            onPressed: onAsk,
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
