import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/room_tabs.dart';
import '../../widgets/status_badge.dart';

/// "Rooms · 3 of 5 available", the room tabs, and the picked room's photos and price.
class RoomsSection extends StatefulWidget {
  const RoomsSection({super.key, required this.rooms});

  /// Already sorted Room 1, Room 2...
  final List<Room> rooms;

  @override
  State<RoomsSection> createState() => _RoomsSectionState();
}

class _RoomsSectionState extends State<RoomsSection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final rooms = widget.rooms;
    final available = rooms.where((r) => r.available).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text('Rooms', style: AppText.title.copyWith(fontSize: 20))),
            if (rooms.isNotEmpty)
              Text(
                '$available of ${rooms.length} available',
                style: AppText.label.copyWith(fontSize: 14, color: AppColors.lagoonDark),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (rooms.isEmpty)
          Text('No rooms listed yet.', style: AppText.secondary)
        else ...[
          RoomTabs(
            labels: [for (final r in rooms) r.name],
            // Rooms can be deleted while this page is open.
            selectedIndex: _selected.clamp(0, rooms.length - 1),
            taken: {for (var i = 0; i < rooms.length; i++) if (!rooms[i].available) i},
            onChanged: (i) => setState(() => _selected = i),
          ),
          const SizedBox(height: 14),
          _RoomDetails(room: rooms[_selected.clamp(0, rooms.length - 1)]),
        ],
      ],
    );
  }
}

class _RoomDetails extends StatelessWidget {
  const _RoomDetails({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final perPerson = room.type == RoomType.bedspace ? ' per person' : '';
    return Column(
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
            Flexible(child: Text(room.name, style: AppText.cardTitle.copyWith(fontSize: 17))),
            const SizedBox(width: 8),
            StatusBadge.room(open: room.available),
          ],
        ),
        const SizedBox(height: 6),
        Text(room.summary, style: AppText.secondary.copyWith(height: 1.45)),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: '₱${formatPesos(room.monthlyPrice)} ',
            style: AppText.label.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
            children: [TextSpan(text: '/ month$perPerson', style: AppText.secondary.copyWith(fontSize: 15))],
          ),
        ),
      ],
    );
  }
}
