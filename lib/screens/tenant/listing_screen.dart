import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/pin_map.dart';
import '../shared/dialogs.dart';
import 'rooms_section.dart';

/// What a student sees after tapping a boarding house: photos, info, rooms, map.
class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key, required this.property, this.school, this.rooms});

  final Property property;

  /// For "450 m from PSU Tiniguiban". Null hides the distance.
  final School? school;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Room>>? rooms;

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  late final _rooms = widget.rooms ?? RoomService().watchForProperty(widget.property.id);

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final pin = LatLng(p.latitude, p.longitude);
    final school = widget.school;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.card,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              Stack(
                children: [
                  PhotoGallery(photos: p.photos, hint: 'Photo gallery · hallway, outside, common area'),
                  const Positioned(top: 8, left: 16, child: SafeArea(child: CircleBackButton())),
                ],
              ),
              // White sheet that slightly covers the bottom of the photos, like the mockup.
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(p.name, style: AppText.largeTitle.copyWith(fontSize: 26)),
                      if (school != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${formatDistance(metersBetween(school.location, pin))} from ${school.shortName}',
                          style: AppText.secondary,
                        ),
                      ],
                      if (p.tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [for (final t in p.tags) _InfoTag(t)],
                        ),
                      ],
                      if (p.description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(p.description, style: AppText.body.copyWith(height: 1.45)),
                      ],
                      const SizedBox(height: 24),
                      StreamBuilder<List<Room>>(
                        stream: _rooms,
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text("Couldn't load rooms. Check your internet.", style: AppText.secondary);
                          }
                          if (!snap.hasData) return const CupertinoActivityIndicator();
                          return RoomsSection(rooms: snap.data!);
                        },
                      ),
                      const SizedBox(height: 28),
                      Text('Location', style: AppText.title.copyWith(fontSize: 20)),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(height: 180, child: PinMap(pin: pin, interactive: false)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _BottomBar(property: p)),
        ],
      ),
    );
  }
}

/// Small gray box tag, like "Wi-Fi" on the mockup.
class _InfoTag extends StatelessWidget {
  const _InfoTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: AppText.label.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}

/// Price range and the Message button, stuck to the bottom.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatPriceRange(property.priceMin, property.priceMax),
                    style: AppText.cardTitle.copyWith(fontSize: 17),
                  ),
                  Text('per month', style: AppText.secondary.copyWith(fontSize: 13)),
                ],
              ),
            ),
            CupertinoButton(
              color: AppColors.lagoon,
              borderRadius: BorderRadius.circular(14),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              // shortcut: chat comes in Week 3.
              onPressed: () => showError(
                context,
                'Chatting with landlords is coming in the next update.',
                title: 'Coming soon',
              ),
              child: Text('Message', style: AppText.label.copyWith(fontSize: 16, color: AppColors.card)),
            ),
          ],
        ),
      ),
    );
  }
}
