import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';
import '../../services/landlord_service.dart';
import '../../services/property_service.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/filter_button.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/pin_map.dart' show defaultMapCenter;
import '../../widgets/price_pin.dart';
import '../../widgets/room_dots.dart';
import '../../widgets/tag_chip.dart';
import 'filter_sheet.dart';
import 'home_logic.dart';
import 'listing_screen.dart';

/// Map of boarding houses with price pins (design-2.0/3-map). Returns the filters when closed with "List".
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.userId,
    required this.school,
    required this.filters,
    this.properties,
    this.rooms,
    this.landlords,
  });

  final String userId;
  final School? school;
  final HomeFilters filters;

  /// Only set in tests. Normally loaded from Firestore.
  final Stream<List<Property>>? properties;
  final Stream<List<Room>>? rooms;
  final Stream<Map<String, LandlordInfo>>? landlords;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final _properties = widget.properties ?? PropertyService().watchAll();
  late final _rooms = widget.rooms ?? RoomService().watchAll();
  late final _landlords = widget.landlords ?? LandlordService().watchAll();
  late HomeFilters _filters = widget.filters;
  final _search = TextEditingController();
  String? _selectedId;

  /// "Near PSU" chip: only houses within a 20-minute walk.
  late bool _nearOnly = widget.school != null;

  static const _under4k = 4000;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _close() => Navigator.pop(context, _filters);

  Future<void> _openFilters() async {
    final picked = await showFilterSheet(context, _filters);
    if (picked != null) setState(() => _filters = picked);
  }

  @override
  Widget build(BuildContext context) {
    final school = widget.school;
    return PopScope(
      canPop: false,
      // Hand the filters back to Home on every way out, including the phone's back gesture.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: CupertinoPageScaffold(
        child: StreamBuilder<List<Property>>(
          stream: _properties,
          builder: (context, places) => StreamBuilder<List<Room>>(
            stream: _rooms,
            builder: (context, rooms) => StreamBuilder<Map<String, LandlordInfo>>(
              stream: _landlords,
              builder: (context, landlords) {
                final byHouse = roomsByHouse(rooms.data ?? const []);
                var list = searchListings(places.data ?? const [], _search.text);
                if (_nearOnly && school != null) list = list.where((p) => isNear(school, p)).toList();
                list = applyFilters(list, byHouse, _filters);
                final selected = list.where((p) => p.id == _selectedId).firstOrNull;

                return Stack(
                  children: [
                    _Map(
                      school: school,
                      places: list,
                      rooms: byHouse,
                      selectedId: selected?.id,
                      onPin: (id) => setState(() => _selectedId = id),
                      onEmpty: () => setState(() => _selectedId = null),
                    ),
                    Positioned(left: 16, right: 16, top: 0, child: SafeArea(child: _topBar(school))),
                    if (places.hasData && list.isEmpty)
                      const Center(child: _Bubble(text: 'No places here match.\nTry fewer filters.')),
                    if (selected != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        child: _PreviewCard(
                          property: selected,
                          rooms: byHouse[selected.id],
                          school: school,
                          onTap: () => Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => ListingScreen(
                                property: selected,
                                school: school,
                                userId: widget.userId,
                                landlord: landlords.data?[selected.landlordId],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 28,
                      child: Center(child: _ListButton(onTap: _close)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(School? school) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [BoxShadow(color: Color(0x1A0F1D20), blurRadius: 18, offset: Offset(0, 6))],
                ),
                child: CupertinoSearchTextField(
                  controller: _search,
                  placeholder: 'Search this area',
                  backgroundColor: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                  style: AppText.body.copyWith(fontSize: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  prefixInsets: const EdgeInsetsDirectional.only(start: 14),
                  itemColor: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilterButton(count: _filters.count, onTap: _openFilters, radius: 25, size: 50),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (school != null) ...[
                TagChip(
                  label: 'Near ${school.code}',
                  outlined: false,
                  selected: _nearOnly,
                  onTap: () => setState(() => _nearOnly = !_nearOnly),
                ),
                const SizedBox(width: 6),
              ],
              TagChip(
                label: 'Open rooms only',
                outlined: false,
                selected: _filters.openOnly,
                onTap: () => setState(() => _filters = _filters.copyWith(openOnly: !_filters.openOnly)),
              ),
              const SizedBox(width: 6),
              TagChip(
                label: 'Under ₱4k',
                outlined: false,
                selected: _filters.maxPrice == _under4k,
                onTap: () => setState(
                  () => _filters = _filters.copyWith(maxPrice: () => _filters.maxPrice == _under4k ? null : _under4k),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The OpenStreetMap with the walk circle, school labels and price pins.
class _Map extends StatelessWidget {
  const _Map({
    required this.school,
    required this.places,
    required this.rooms,
    required this.selectedId,
    required this.onPin,
    required this.onEmpty,
  });

  final School? school;
  final List<Property> places;
  final Map<String, HouseRooms> rooms;
  final String? selectedId;
  final ValueChanged<String> onPin;
  final VoidCallback onEmpty;

  @override
  Widget build(BuildContext context) {
    final s = school;
    return FlutterMap(
      options: MapOptions(
        initialCenter: s?.location ?? defaultMapCenter,
        initialZoom: 15,
        onTap: (_, _) => onEmpty(),
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boardmate.boardmate',
        ),
        if (s != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: s.location,
                radius: nearSchoolMinutes * walkMetersPerMinute,
                useRadiusInMeter: true,
                color: const Color(0x120B6E5F),
                borderColor: AppColors.lagoon,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final sc in schools)
              Marker(
                point: sc.location,
                width: 110,
                height: 64,
                child: _SchoolMarker(label: sc.code, picked: sc.id == s?.id),
              ),
            // The picked pin is drawn last so it sits on top.
            for (final p in [...places.where((p) => p.id != selectedId), ...places.where((p) => p.id == selectedId)])
              Marker(
                point: LatLng(p.latitude, p.longitude),
                width: 160,
                height: 44,
                child: Center(
                  child: PricePin(
                    price: '₱${formatPesos(fromPrice(p, rooms[p.id]))}',
                    openRooms: rooms[p.id]?.open ?? 0,
                    selected: p.id == selectedId,
                    onTap: () => onPin(p.id),
                  ),
                ),
              ),
          ],
        ),
        // OpenStreetMap requires this credit on the map.
        const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}

class _SchoolMarker extends StatelessWidget {
  const _SchoolMarker({required this.label, required this.picked});

  final String label;
  final bool picked;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (picked)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.lagoon,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: AppColors.card, spreadRadius: 4)],
            ),
            child: const Icon(CupertinoIcons.book_fill, size: 17, color: AppColors.card),
          ),
        if (picked) const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: const Color(0xD9FFFFFF), borderRadius: BorderRadius.circular(6)),
          child: Text(
            label,
            style: AppText.small.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: picked ? AppColors.lagoonDark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// White card at the bottom after tapping a pin.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.property, required this.rooms, required this.school, required this.onTap});

  final Property property;
  final HouseRooms? rooms;
  final School? school;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final s = school;
    return Semantics(
      button: true,
      label: 'Open ${p.name}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [BoxShadow(color: Color(0x290F1D20), blurRadius: 30, offset: Offset(0, 12))],
          ),
          child: Row(
            children: [
              PhotoBox(imageUrl: p.photos.isEmpty ? null : p.photos.first, width: 92, height: 92, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.section),
                    const SizedBox(height: 4),
                    Text(
                      s == null ? p.place : walkText(distanceTo(s, p), s),
                      style: AppText.secondary.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if ((rooms?.total ?? 0) > 0)
                          RoomDots(open: rooms!.open, total: rooms!.total, showLabel: false, size: 12),
                        const Spacer(),
                        Text('from ₱${formatPesos(fromPrice(p, rooms))}', style: AppText.price.copyWith(fontSize: 15)),
                      ],
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

/// Ink pill at the bottom that goes back to the list.
class _ListButton extends StatelessWidget {
  const _ListButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to the list',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [BoxShadow(color: Color(0x470F1D20), blurRadius: 30, offset: Offset(0, 12))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.list_bullet, size: 19, color: AppColors.card),
              const SizedBox(width: 8),
              Text('List', style: AppText.label.copyWith(fontSize: 15, color: AppColors.card)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
      child: Text(text, textAlign: TextAlign.center, style: AppText.label),
    );
  }
}
