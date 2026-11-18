import 'package:latlong2/latlong.dart';

import '../../models/property.dart';
import '../../models/room.dart';
import '../../models/school.dart';

/// Boarding houses this close to the school count as "near" on the live board.
const nearSchoolMeters = 3000.0;

double distanceTo(School school, Property p) => metersBetween(school.location, LatLng(p.latitude, p.longitude));

/// Closest to [school] first. Without a school, A to Z.
List<Property> sortByDistance(List<Property> places, School? school) {
  final list = [...places];
  if (school == null) {
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  } else {
    list.sort((a, b) => distanceTo(school, a).compareTo(distanceTo(school, b)));
  }
  return list;
}

/// Keeps boarding houses whose name, tags or description contain [query] (any case).
List<Property> searchListings(List<Property> places, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return places;
  return places
      .where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q)))
      .toList();
}

/// Numbers for the dark live board on Home.
class LiveStats {
  const LiveStats({required this.open, required this.tiles, required this.updatedToday, this.cheapest});

  /// Open rooms near the school (or in the whole city without a school).
  final int open;

  /// One entry per room, closest boarding house first: true = open. At most [maxTiles].
  final List<bool> tiles;

  /// Open rooms the landlord saved in the last 24 hours.
  final int updatedToday;

  /// Cheapest open room's monthly price, or null if none.
  final int? cheapest;

  static const maxTiles = 20;

  factory LiveStats.from(List<Property> places, List<Room> rooms, School? school, {DateTime? now}) {
    final near = school == null
        ? sortByDistance(places, null)
        : sortByDistance(places, school).where((p) => distanceTo(school, p) <= nearSchoolMeters).toList();
    final order = {for (var i = 0; i < near.length; i++) near[i].id: i};
    final nearRooms = rooms.where((r) => order.containsKey(r.propertyId)).toList()
      ..sort((a, b) => order[a.propertyId]!.compareTo(order[b.propertyId]!));

    final open = nearRooms.where((r) => r.available).toList();
    final dayAgo = (now ?? DateTime.now()).subtract(const Duration(hours: 24));
    return LiveStats(
      open: open.length,
      tiles: [for (final r in nearRooms.take(maxTiles)) r.available],
      updatedToday: open.where((r) => r.updatedAt?.isAfter(dayAgo) ?? false).length,
      cheapest: open.isEmpty ? null : open.map((r) => r.monthlyPrice).reduce((a, b) => a < b ? a : b),
    );
  }
}
