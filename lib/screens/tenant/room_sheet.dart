import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/cost_card.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';
import '../shared/dialogs.dart';

/// Opens the room details as a sheet from the bottom (design-2.0/5-room).
Future<void> showRoomSheet(BuildContext context, Room room) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => RoomSheet(room: room),
  );
}

/// Rent + each bill, for the "Real monthly cost" card. Adds up to [Room.estimatedMonthly].
List<CostLine> roomCostLines(Room r) => [
  CostLine(r.type == RoomType.bedspace ? 'Rent per person' : 'Rent', r.monthlyPrice),
  switch (r.electricity) {
    ElectricityCost.included => const CostLine.included('Electricity'),
    ElectricityCost.ownMeter =>
      r.electricityEstimate > 0
          ? CostLine('Electricity · own meter', r.electricityEstimate, estimate: true)
          : const CostLine.note('Electricity', 'own meter'),
  },
  switch (r.water) {
    WaterCost.included => const CostLine.included('Water'),
    WaterCost.separate => const CostLine.note('Water', 'separate'),
  },
  switch (r.wifi) {
    WifiCost.included => const CostLine.included('Wi-Fi'),
    WifiCost.paid => CostLine('Wi-Fi', r.wifiPrice),
    WifiCost.none => const CostLine.note('Wi-Fi', 'none'),
  },
];

class RoomSheet extends StatelessWidget {
  const RoomSheet({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final r = room;
    final details = [
      r.floor == RoomFloor.ground ? 'Ground floor' : r.floor.label,
      r.type == RoomType.solo ? 'solo room' : 'bedspace for ${r.capacity}',
      r.privateCr ? 'own CR' : 'shared CR',
    ].join(' · ');

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(r.name, style: AppText.title.copyWith(fontSize: 30, letterSpacing: -0.8)),
                              StatusBadge.room(open: r.available),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(details, style: AppText.secondary),
                        ],
                      ),
                    ),
                    CloseCircleButton(onTap: () => Navigator.pop(context), color: AppColors.background),
                  ],
                ),
                const SizedBox(height: 16),
                _PhotoGrid(photos: r.photos),
                const SizedBox(height: 16),
                _IncludedTiles(room: r),
                const SizedBox(height: 16),
                CostCard(lines: roomCostLines(r), moveIn: r.moveIn),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Ask about ${r.name}',
                  color: AppColors.lagoon,
                  // shortcut: chat comes in Week 3.
                  onPressed: () => showInfo(
                    context,
                    title: 'Coming soon',
                    message: 'Chatting with landlords is coming in the next update.',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text('Never send a deposit before you visit.', style: AppText.secondary.copyWith(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One big photo and two small ones; the last small one says "+6 photos". Tap to see them all.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    String? at(int i) => i < photos.length ? photos[i] : null;
    final more = photos.length - 3;
    void open() {
      if (photos.isEmpty) return;
      Navigator.of(context)
          .push(CupertinoPageRoute(fullscreenDialog: true, builder: (_) => _PhotoViewer(photos: photos)));
    }

    return Semantics(
      button: photos.isNotEmpty,
      label: 'Room photos, ${photos.length}',
      child: GestureDetector(
        onTap: open,
        child: SizedBox(
          height: 134,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PhotoBox(imageUrl: at(0), hint: 'Room photo', sand: true, radius: 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PhotoBox(imageUrl: at(1), hint: 'CR', radius: 14),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PhotoBox(imageUrl: at(2), hint: '', radius: 14),
                          if (more > 0)
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0x990F1D20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text('+$more photos', style: AppText.small.copyWith(color: AppColors.card)),
                            ),
                        ],
                      ),
                    ),
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

/// Full-screen swipeable photos with a close button.
class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.ink,
      child: SafeArea(
        child: Stack(
          children: [
            Center(child: PhotoGallery(photos: photos, height: 420)),
            Positioned(top: 8, right: 16, child: CloseCircleButton(onTap: () => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }
}

/// Gray tiles with an icon for each included item, plus the CR.
class _IncludedTiles extends StatelessWidget {
  const _IncludedTiles({required this.room});

  final Room room;

  static IconData _icon(String item) {
    final s = item.toLowerCase();
    if (s.contains('bed') || s.contains('mattress')) return CupertinoIcons.bed_double;
    if (s.contains('fan')) return CupertinoIcons.wind;
    if (s.contains('aircon')) return CupertinoIcons.snow;
    if (s.contains('table') || s.contains('desk') || s.contains('chair')) return CupertinoIcons.pencil_outline;
    if (s.contains('cabinet')) return CupertinoIcons.archivebox;
    if (s.contains('window')) return CupertinoIcons.sun_max;
    return CupertinoIcons.checkmark_alt;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final i in room.included) (label: i, icon: _icon(i)),
      (label: room.privateCr ? 'Own CR' : 'Shared CR', icon: CupertinoIcons.drop),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - 3 * 8) / 4;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(item.icon, size: 22, color: AppColors.ink),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
