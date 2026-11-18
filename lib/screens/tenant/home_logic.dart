import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';

/// Boarding houses within this walk count as "near" the school.
const nearSchoolMinutes = 20;

double distanceTo(School school, Property p) => metersBetween(school.location, LatLng(p.latitude, p.longitude));

bool isNear(School school, Property p) => walkMinutes(distanceTo(school, p)) <= nearSchoolMinutes;

/// Room numbers for one boarding house.
class HouseRooms {
  const HouseRooms({this.open = 0, this.total = 0, this.cheapestOpen, this.lastUpdate});

  final int open;
  final int total;

  /// Lowest monthly price among open rooms.
  final int? cheapestOpen;

  /// Newest time the landlord saved one of the rooms.
  final DateTime? lastUpdate;

  bool get full => open == 0;
}

/// propertyId → its room numbers. Houses without rooms are left out.
Map<String, HouseRooms> roomsByHouse(Iterable<Room> rooms) {
  final out = <String, HouseRooms>{};
  for (final r in rooms) {
    final h = out[r.propertyId] ?? const HouseRooms();
    final cheapest = !r.available
        ? h.cheapestOpen
        : (h.cheapestOpen == null || r.monthlyPrice < h.cheapestOpen! ? r.monthlyPrice : h.cheapestOpen);
    final last = r.updatedAt == null || (h.lastUpdate?.isAfter(r.updatedAt!) ?? false) ? h.lastUpdate : r.updatedAt;
    out[r.propertyId] = HouseRooms(
      open: h.open + (r.available ? 1 : 0),
      total: h.total + 1,
      cheapestOpen: cheapest,
      lastUpdate: last,
    );
  }
  return out;
}

/// When the landlord last confirmed anything: the house or any of its rooms.
DateTime? lastChecked(Property p, HouseRooms? rooms) {
  final a = p.updatedAt;
  final b = rooms?.lastUpdate;
  if (a == null) return b;
  if (b == null) return a;
  return a.isAfter(b) ? a : b;
}

/// Houses with open rooms first, then the rest. Within each group: shortest walk first
/// (or A to Z without a school).
List<Property> sortForHome(List<Property> places, Map<String, HouseRooms> rooms, School? school) {
  int group(Property p) => (rooms[p.id]?.open ?? 0) > 0 ? 0 : 1;
  final list = [...places];
  list.sort((a, b) {
    final g = group(a).compareTo(group(b));
    if (g != 0) return g;
    if (school == null) return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return distanceTo(school, a).compareTo(distanceTo(school, b));
  });
  return list;
}

/// Keeps boarding houses whose name, area, tags or description contain [query] (any case).
List<Property> searchListings(List<Property> places, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return places;
  return places
      .where(
        (p) =>
            p.name.toLowerCase().contains(q) ||
            p.area.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q)),
      )
      .toList();
}

/// Numbers for the dark live board on Home.
class LiveStats {
  const LiveStats({required this.open, required this.tiles, required this.openedToday, this.cheapest});

  /// Open rooms within a 20-minute walk of the school (or in the whole city without a school).
  final int open;

  /// One entry per room, closest boarding house first: true = open. At most [maxTiles].
  final List<bool> tiles;

  /// Rooms that became open in the last 24 hours.
  final int openedToday;

  /// Cheapest open room's monthly price, or null if none.
  final int? cheapest;

  static const maxTiles = 20;

  factory LiveStats.from(List<Property> places, List<Room> rooms, School? school, {DateTime? now}) {
    final near = school == null
        ? places
        : ([...places.where((p) => isNear(school, p))]
            ..sort((a, b) => distanceTo(school, a).compareTo(distanceTo(school, b))));
    final order = {for (var i = 0; i < near.length; i++) near[i].id: i};
    final nearRooms = rooms.where((r) => order.containsKey(r.propertyId)).toList()
      ..sort((a, b) => order[a.propertyId]!.compareTo(order[b.propertyId]!));

    final open = nearRooms.where((r) => r.available).toList();
    final dayAgo = (now ?? DateTime.now()).subtract(const Duration(hours: 24));
    return LiveStats(
      open: open.length,
      tiles: [for (final r in nearRooms.take(maxTiles)) r.available],
      openedToday: open.where((r) => r.openedAt?.isAfter(dayAgo) ?? false).length,
      cheapest: open.isEmpty ? null : open.map((r) => r.monthlyPrice).reduce((a, b) => a < b ? a : b),
    );
  }
}
