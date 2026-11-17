import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/room_row.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/section_header.dart';
import 'property_form_screen.dart';
import 'room_form_screen.dart';

/// Landlord home: their boarding house and its rooms, or a button to add one.
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
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

/// Opens a screen on top of the tab bar.
void _push(BuildContext context, Widget screen) {
  Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (_) => screen));
}

class _PropertyDashboard extends StatelessWidget {
  const _PropertyDashboard({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    void editProperty() => _push(
          context,
          PropertyFormScreen(landlordId: property.landlordId, existing: property),
        );

    return StreamBuilder<List<Room>>(
      stream: RoomService().watchForProperty(property.id),
      builder: (context, snap) {
        final rooms = snap.data ?? const <Room>[];
        final available = rooms.where((r) => r.available).length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            _Header(title: property.name),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatTile(number: available, label: 'Available'),
                const SizedBox(width: 10),
                _StatTile(number: rooms.length - available, label: 'Taken'),
                const SizedBox(width: 10),
                _StatTile(number: rooms.length, label: 'Rooms'),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Rooms',
              actionLabel: '+ Add room',
              onAction: () => _push(
                context,
                RoomFormScreen(property: property, suggestedName: 'Room ${rooms.length + 1}'),
              ),
            ),
            const SizedBox(height: 4),
            if (snap.hasError)
              Text("Couldn't load rooms.", style: AppText.secondary)
            else if (!snap.hasData)
              const Center(child: CupertinoActivityIndicator())
            else if (rooms.isEmpty)
              RoundedCard(
                shadow: false,
                radius: 16,
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No rooms yet. Tap "+ Add room" to add your first room with its photos and price.',
                  style: AppText.secondary.copyWith(height: 1.4),
                ),
              )
            else
              RoundedCard(
                shadow: false,
                radius: 16,
                child: Column(
                  children: [
                    for (var i = 0; i < rooms.length; i++) ...[
                      if (i > 0) Container(height: 0.5, color: AppColors.divider),
                      RoomRow(
                        room: rooms[i],
                        onTap: () => _push(
                          context,
                          RoomFormScreen(property: property, existing: rooms[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 28),
            Text('How students see your place', style: AppText.section),
            const SizedBox(height: 12),
            ListingCard(
              name: property.name,
              subtitle: property.tags.isEmpty ? 'Puerto Princesa' : property.tags.take(3).join(' · '),
              priceText: formatPriceRange(property.priceMin, property.priceMax),
              photoUrl: property.photos.isEmpty ? null : property.photos.first,
              roomsAvailable: snap.hasData && rooms.isNotEmpty ? available : null,
              onTap: editProperty,
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

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LANDLORD MODE',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.tealDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: AppText.largeTitle.copyWith(fontSize: 30)),
      ],
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
      child: RoundedCard(
        shadow: false,
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$number', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(label, style: AppText.secondary.copyWith(fontSize: 13)),
          ],
        ),
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
            decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.house, color: AppColors.teal, size: 30),
          ),
          const SizedBox(height: 16),
          Text('List your boarding house', style: AppText.cardTitle.copyWith(fontSize: 19)),
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
