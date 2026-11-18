import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/landlord_service.dart';
import '../../services/room_service.dart';
import '../../services/saved_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/freshness_badge.dart';
import '../../widgets/heart_button.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/pin_map.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/walk_pill.dart';
import '../shared/dialogs.dart';
import 'home_logic.dart';
import 'house_card.dart' show toggleSaved;
import 'house_rooms_card.dart';
import 'share_house.dart';

/// The boarding house page (design-2.0/4-house and 4b-house-no-rooms).
class ListingScreen extends StatefulWidget {
  const ListingScreen({
    super.key,
    required this.property,
    this.school,
    this.userId,
    this.rooms,
    this.savedIds,
    this.landlord,
  });

  final Property property;

  /// For the walk time. Null hides it.
  final School? school;

  /// The student looking at it. Null hides the heart.
  final String? userId;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Room>>? rooms;
  final Stream<List<String>>? savedIds;

  /// Public landlord info: "Listed by Nathan" and the "Verified owner" chip. Null hides both.
  final LandlordInfo? landlord;

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  late final _rooms = widget.rooms ?? RoomService().watchForProperty(widget.property.id);
  late final Stream<List<String>>? _savedIds =
      widget.savedIds ?? (widget.userId == null ? null : SavedService().watchIds(widget.userId!));

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: StreamBuilder<List<Room>>(
        stream: _rooms,
        builder: (context, snap) {
          final rooms = snap.data;
          final stats = rooms == null ? null : roomsByHouse(rooms)[widget.property.id];
          return Column(
            children: [
              StreamBuilder<List<String>>(
                stream: _savedIds,
                builder: (context, saved) => _Header(
                  property: widget.property,
                  saved: _savedIds == null ? null : (saved.data?.contains(widget.property.id) ?? false),
                  onSave: (nowSaved) =>
                      toggleSaved(context, userId: widget.userId!, propertyId: widget.property.id, saved: nowSaved),
                  onShare: () => shareHouse(context, shareText(widget.property, stats, widget.school)),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 130), children: _body(snap, stats)),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _BottomBar(property: widget.property, rooms: stats),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _body(AsyncSnapshot<List<Room>> snap, HouseRooms? stats) {
    final p = widget.property;
    final school = widget.school;
    final pin = LatLng(p.latitude, p.longitude);
    final hasRooms = (stats?.total ?? 0) > 0;
    final tags = [for (final t in p.tags) _OutlineChip(t)];

    return [
      PhotoGallery(
        photos: p.photos,
        height: 220,
        radius: 24,
        hint: 'Photos · outside, hallway, common area',
        bottomLeft: school == null ? null : WalkPill(text: walkText(distanceTo(school, p), school)),
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name, style: AppText.title.copyWith(fontSize: 28, letterSpacing: -0.7)),
            if (widget.landlord != null && widget.landlord!.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Listed by ${widget.landlord!.firstName}', style: AppText.secondary),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // With no rooms the tags sit up here (4b); otherwise they go under the Room Map (4).
                if (!hasRooms) ...tags,
                // shortcut: reviews come in Week 3, so every house is "New" for now.
                if (widget.landlord?.verified ?? false) const _VerifiedChip(),
                const _WhiteChip('New · no reviews yet'),
                if (hasRooms) FreshnessBadge(checkedAt: lastChecked(p, stats), pill: true),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      if (snap.hasError)
        Text("Couldn't load rooms. Check your internet.", style: AppText.secondary)
      else if (!snap.hasData)
        const Padding(padding: EdgeInsets.all(24), child: CupertinoActivityIndicator())
      else
        HouseRoomsCard(rooms: snap.data!),
      if (hasRooms && tags.isNotEmpty) ...[const SizedBox(height: 14), Wrap(spacing: 6, runSpacing: 6, children: tags)],
      if (p.description.isNotEmpty) ...[
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(p.description, style: AppText.body.copyWith(fontSize: 15, height: 1.45)),
        ),
      ],
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text('Location', style: AppText.section),
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(height: 160, child: PinMap(pin: pin, interactive: false)),
      ),
    ];
  }
}

/// Pinned top bar: back, name + area, Share, Save.
class _Header extends StatelessWidget {
  const _Header({required this.property, required this.saved, required this.onSave, required this.onShare});

  final Property property;

  /// Null hides the heart.
  final bool? saved;
  final ValueChanged<bool> onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Row(
            children: [
              const CircleBackButton(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      property.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.secondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Share',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: onShare,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.share, size: 20, color: AppColors.ink),
                  ),
                ),
              ),
              if (saved != null) ...[
                const SizedBox(width: 8),
                HeartButton(saved: saved!, onTap: () => onSave(!saved!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "2 rooms open from ₱3,500 /mo" + Plan a visit, or the price range + Message when nothing is open.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.property, required this.rooms});

  final Property property;
  final HouseRooms? rooms;

  @override
  Widget build(BuildContext context) {
    final open = rooms?.open ?? 0;
    final String caption;
    final String price;
    final String button;
    if (open > 0) {
      caption = '$open ${open == 1 ? 'room' : 'rooms'} open from';
      price = '₱${formatPesos(rooms!.cheapestOpen!)}';
      button = 'Plan a visit';
    } else {
      caption = 'Price range';
      price = formatPriceRange(property.priceMin, property.priceMax);
      button = 'Message';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x0F0F1D20), blurRadius: 24, offset: Offset(0, -8))],
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
                  Text(caption, style: AppText.secondary.copyWith(fontSize: 12)),
                  Text.rich(
                    TextSpan(
                      text: price,
                      style: AppText.price.copyWith(fontSize: 20),
                      children: [TextSpan(text: ' /mo', style: AppText.secondary.copyWith(fontSize: 13))],
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: button,
              expand: false,
              icon: open > 0 ? CupertinoIcons.calendar : null,
              // shortcut: visits and chat come in Week 3.
              onPressed: () => showInfo(
                context,
                title: 'Coming soon',
                message: open > 0
                    ? 'Booking a visit is coming in the next update.'
                    : 'Chatting with landlords is coming in the next update.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tag like "Wi-Fi": thin outline pill.
class _OutlineChip extends StatelessWidget {
  const _OutlineChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppText.small.copyWith(fontWeight: FontWeight.w500)),
    );
  }
}

/// White pill like "New · no reviews yet".
class _WhiteChip extends StatelessWidget {
  const _WhiteChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: AppText.small.copyWith(color: AppColors.textSecondary)),
    );
  }
}

/// White pill with a lagoon shield: "Verified owner".
class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.checkmark_shield, size: 15, color: AppColors.lagoon),
          const SizedBox(width: 5),
          Text('Verified owner', style: AppText.small),
        ],
      ),
    );
  }
}
