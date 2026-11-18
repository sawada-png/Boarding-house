import 'package:latlong2/latlong.dart';

/// A school students can pick, so listings show how far they are.
class School {
  const School({
    required this.id,
    required this.code,
    required this.shortName,
    required this.fullName,
    required this.location,
  });

  /// Saved in users/{uid}.school.
  final String id;

  /// "PSU": on pills and "6 min walk to PSU".
  final String code;

  /// "PSU Tiniguiban"
  final String shortName;
  final String fullName;
  final LatLng location;
}

// Points from OpenStreetMap (Nov 2026).
const schools = [
  School(
    id: 'psu',
    code: 'PSU',
    shortName: 'PSU Tiniguiban',
    fullName: 'Palawan State University',
    location: LatLng(9.7768, 118.7338),
  ),
  School(
    id: 'wpu',
    code: 'WPU',
    shortName: 'WPU PPC',
    fullName: 'Western Philippines University',
    location: LatLng(9.7843, 118.7274),
  ),
  School(
    id: 'htu',
    code: 'Holy Trinity',
    shortName: 'Holy Trinity',
    fullName: 'Holy Trinity University',
    location: LatLng(9.7419, 118.7326),
  ),
];

School? schoolById(String? id) {
  for (final s in schools) {
    if (s.id == id) return s;
  }
  return null;
}

// shortcut: straight-line distance, not walking distance; good enough to sort nearby places.
double metersBetween(LatLng a, LatLng b) => const Distance().as(LengthUnit.Meter, a, b);

/// 447 → "450 m", 1234 → "1.2 km".
String formatDistance(double meters) {
  final rounded = (meters / 10).round() * 10;
  if (rounded < 1000) return '$rounded m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
