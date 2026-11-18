import 'package:cupertino_ui/cupertino_ui.dart';

import '../models/property.dart';
import '../models/room.dart';
import '../theme/app_text_styles.dart';
import 'photo_box.dart';
import 'status_badge.dart';

/// One room in the landlord's list: photo, name, price and type, available/taken badge.
class RoomRow extends StatelessWidget {
  const RoomRow({super.key, required this.room, this.onTap});

  final Room room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PhotoBox(
              imageUrl: room.photos.isEmpty ? null : room.photos.first,
              sand: true,
              width: 44,
              height: 44,
              radius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: AppText.label.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    '₱${formatPesos(room.monthlyPrice)} · ${room.typeLabel.toLowerCase()}',
                    style: AppText.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            StatusBadge.room(open: room.available),
          ],
        ),
      ),
    );
  }
}
