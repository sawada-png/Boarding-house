import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/room_tabs.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tag_chip.dart';

/// Student home tab.
// shortcut: shows sample data to preview the design; Week 2 loads real listings from Firestore.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _filters = ['Under ₱4k', 'Girls only', 'Wi-Fi', 'No curfew'];
  final _selectedFilters = <String>{'Under ₱4k'};
  int _room = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            _header(),
            const SizedBox(height: 16),
            CupertinoSearchTextField(
              placeholder: 'Search boarding houses, areas',
              backgroundColor: AppColors.searchFill,
              borderRadius: BorderRadius.circular(12),
              style: AppText.body,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in _filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TagChip(
                        label: f,
                        selected: _selectedFilters.contains(f),
                        onTap: () => setState(() {
                          _selectedFilters.contains(f)
                              ? _selectedFilters.remove(f)
                              : _selectedFilters.add(f);
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(title: 'Closest to campus', actionLabel: 'See all'),
            const SizedBox(height: 4),
            const ListingCard(
              name: "Nathan's Boarding House",
              subtitle: '450 m from PSU · Tiniguiban',
              priceText: '₱3,000–4,500',
              roomsAvailable: 3,
              rating: 4.8,
              reviewCount: 32,
            ),
            const SizedBox(height: 28),
            Text('Room tabs (preview)', style: AppText.section),
            const SizedBox(height: 12),
            RoomTabs(
              labels: const ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
              selectedIndex: _room,
              taken: const {2},
              onChanged: (i) => setState(() => _room = i),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Room ${_room + 1}', style: AppText.cardTitle),
                const SizedBox(width: 8),
                StatusBadge.room(available: _room != 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.location, size: 16, color: AppColors.teal),
                  const SizedBox(width: 4),
                  Text('Near PSU Tiniguiban',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Find your room', style: AppText.largeTitle),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
          child: Text('B',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.teal)),
        ),
      ],
    );
  }
}
