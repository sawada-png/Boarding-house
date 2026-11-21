import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../../widgets/freshness_badge.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/room_map.dart';
import '../../widgets/room_row.dart';
import '../../widgets/rounded_card.dart';
import '../shared/dialogs.dart';
import '../tenant/home_logic.dart';
import '../tenant/house_rooms_card.dart' show roomMapFloors;
import '../tenant/listing_screen.dart';
import 'property_form_screen.dart';
import 'room_form_screen.dart';

/// Landlord home (design-2.0/7-landlord): their boarding house, stats and Room Map, or a button to add one.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Property>>(
          stream: PropertyService().watchMine(profile.uid),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text("Couldn't load your listing.", style: AppText.secondary));
            }
            if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());

            // shortcut: shows the first boarding house only; add a switcher if a landlord owns several.
            final property = snap.data!.isEmpty ? null : snap.data!.first;
            if (property == null) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
                children: [
                  _Header(title: 'Hi, ${profile.name.split(' ').first}!'),
                  const SizedBox(height: 20),
                  _EmptyState(onAdd: () => _push(context, PropertyFormScreen(landlordId: profile.uid))),
                ],
              );
            }
            return _PropertyDashboard(key: ValueKey(property.id), property: property);
          },
        ),
      ),
    );
  }
}

/// Days before the dashboard asks "Is Room 4 still open?".
const weeklyCheckDays = 7;

/// The open room that went longest without a check, if that's over a week. Null if all are fresh.
Room? roomToCheck(List<Room> rooms, {DateTime? now}) {
  final n = now ?? DateTime.now();
  Room? oldest;
  for (final r in rooms) {
    final at = r.updatedAt;
    if (!r.available || at == null || n.difference(at).inDays < weeklyCheckDays) continue;
    if (oldest == null || at.isBefore(oldest.updatedAt!)) oldest = r;
  }
  return oldest;
}

/// Opens a screen on top of the tab bar.
void _push(BuildContext context, Widget screen) {
  Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (_) => screen));
}

class _PropertyDashboard extends StatelessWidget {
  const _PropertyDashboard({super.key, required this.property});

  final Property property;

  Future<void> _toggle(BuildContext context, Room room) async {
    final open = !room.available;
    try {
      await RoomService().setOpen(room, open);
      if (context.mounted) showToast(context, '${room.name} is now ${open ? 'open' : 'taken'}');
    } catch (_) {
      if (context.mounted) await showError(context, "Couldn't switch the room. Check your internet and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    void editProperty() => _push(context, PropertyFormScreen(landlordId: property.landlordId, existing: property));

    return StreamBuilder<List<Room>>(
      stream: RoomService().watchForProperty(property.id),
      builder: (context, snap) {
        final rooms = snap.data ?? const <Room>[];
        final open = rooms.where((r) => r.available).length;
        final houseRooms = roomsByHouse(rooms)[property.id];
        final checked = lastChecked(property, houseRooms);
        void addRoom() => _push(context, RoomFormScreen(property: property, suggestedName: 'Room ${rooms.length + 1}'));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, BmTabScaffold.bottomSpace),
          children: [
            Row(
              children: [
                Expanded(child: _Header(title: property.name)),
                const SizedBox(width: 10),
                _FreshPill(checkedAt: checked),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _StatTile(number: open, label: 'open'),
                const SizedBox(width: 8),
                _StatTile(number: rooms.length - open, label: 'taken'),
                const SizedBox(width: 8),
                // Only the number: who saved stays private.
                _StatTile(number: property.saveCount, label: property.saveCount == 1 ? 'save' : 'saves'),
              ],
            ),
            if (roomToCheck(rooms) case final stale?) ...[const SizedBox(height: 16), _WeeklyCheck(room: stale)],
            const SizedBox(height: 16),
            if (snap.hasError)
              Text("Couldn't load rooms.", style: AppText.secondary)
            else if (!snap.hasData)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (rooms.isEmpty)
              _NoRooms(onAdd: addRoom)
            else ...[
              RoomMap(
                title: 'Your Room Map',
                floors: roomMapFloors(rooms),
                onTap: (tile) => _toggle(context, rooms.firstWhere((r) => r.id == tile.id)),
                trailing: _Link(label: '+ Add room', onTap: addRoom),
                hint: 'Tap a room to switch open / taken.',
              ),
              const SizedBox(height: 16),
              Text('Edit a room', style: AppText.section),
              const SizedBox(height: 10),
              RoundedCard(
                shadow: false,
                child: Column(
                  children: [
                    for (var i = 0; i < rooms.length; i++) ...[
                      if (i > 0) Container(height: 1, color: AppColors.divider),
                      RoomRow(
                        room: rooms[i],
                        onTap: () => _push(context, RoomFormScreen(property: property, existing: rooms[i])),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('How students see your place', style: AppText.section),
            const SizedBox(height: 10),
            ListingCard(
              name: property.name,
              subtitle: property.area.isEmpty ? 'Puerto Princesa' : property.area,
              fromPrice: '₱${formatPesos(houseRooms?.cheapestOpen ?? property.priceMin)}',
              photoUrl: property.photos.isEmpty ? null : property.photos.first,
              openRooms: houseRooms?.open ?? 0,
              totalRooms: houseRooms?.total ?? 0,
              checkedAt: checked,
              onTap: () => _push(context, ListingScreen(property: property)),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Edit boarding house',
              secondary: true,
              icon: CupertinoIcons.pencil,
              onPressed: editProperty,
            ),
          ],
        );
      },
    );
  }
}

/// "Is Room 4 still open?" with Yes / No. Keeps the "Rooms checked" badge fresh for students.
class _WeeklyCheck extends StatelessWidget {
  const _WeeklyCheck({required this.room});

  final Room room;

  Future<void> _answer(BuildContext context, bool open) async {
    try {
      if (open) {
        await RoomService().stillOpen(room);
      } else {
        await RoomService().setOpen(room, false);
      }
      if (context.mounted) showToast(context, open ? 'Thanks! ${room.name} stays open' : '${room.name} is now taken');
    } catch (_) {
      if (context.mounted) await showError(context, "Couldn't save. Check your internet and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      color: AppColors.ink,
      shadow: false,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'WEEKLY CHECK',
            style: AppText.small.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.onInkGood),
          ),
          const SizedBox(height: 4),
          Text('Is ${room.name} still open?', style: AppText.section.copyWith(fontSize: 20, color: AppColors.card)),
          const SizedBox(height: 4),
          Text(
            'Students trust rooms that were checked this week.',
            style: AppText.secondary.copyWith(color: AppColors.onInkMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: "No, it's taken",
                  color: AppColors.inkRaised,
                  onPressed: () => _answer(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Yes, open',
                  color: AppColors.lagoon,
                  onPressed: () => _answer(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Landlord mode', style: AppText.label.copyWith(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(title, style: AppText.largeTitle.copyWith(fontSize: 30, letterSpacing: -0.8)),
      ],
    );
  }
}

/// "● Fresh" when rooms were checked in the last 2 weeks, otherwise "● Check rooms".
class _FreshPill extends StatelessWidget {
  const _FreshPill({required this.checkedAt});

  final DateTime? checkedAt;

  @override
  Widget build(BuildContext context) {
    final at = checkedAt;
    final fresh = at != null && DateTime.now().difference(at).inDays <= FreshnessBadge.staleAfterDays;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fresh ? AppColors.lagoonLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fresh ? AppColors.lagoon : AppColors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            fresh ? 'Fresh' : 'Check rooms',
            style: AppText.small.copyWith(
              fontWeight: FontWeight.w700,
              color: fresh ? AppColors.lagoonDark : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$number', style: AppText.title),
            const SizedBox(height: 2),
            Text(label, style: AppText.secondary.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: onTap,
      child: Text(label, style: AppText.label.copyWith(color: AppColors.lagoon)),
    );
  }
}

class _NoRooms extends StatelessWidget {
  const _NoRooms({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      shadow: false,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your Room Map', style: AppText.section),
          const SizedBox(height: 6),
          Text(
            'No rooms yet. Add each room with its floor, photos and price, and it shows up here.',
            style: AppText.secondary.copyWith(height: 1.4),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Add your first room', icon: CupertinoIcons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.lagoonLight, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.house, color: AppColors.lagoon, size: 30),
          ),
          const SizedBox(height: 16),
          Text('List your boarding house', style: AppText.cardTitle),
          const SizedBox(height: 6),
          Text(
            'Add photos, the location and your prices. Students near campus will find you here.',
            textAlign: TextAlign.center,
            style: AppText.secondary.copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Add boarding house', icon: CupertinoIcons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}
