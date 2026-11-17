import 'package:cloud_firestore/cloud_firestore.dart';

/// Ready-made tags a landlord can tap. They can also type their own.
const propertyTagOptions = [
  'Wi-Fi',
  'Girls only',
  'Boys only',
  'No curfew',
  'Visitors allowed',
  'Water included',
  'Electric included',
  'Study area',
  'Shared kitchen',
  'Parking',
];

/// A boarding house, saved in Firestore at properties/{id}.
class Property {
  const Property({
    this.id = '',
    required this.landlordId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.priceMin,
    required this.priceMax,
    this.description = '',
    this.photos = const [],
    this.tags = const [],
  });

  /// Empty until it's saved the first time.
  final String id;
  final String landlordId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;

  /// Download links of the uploaded photos. The first one is the cover.
  final List<String> photos;

  /// Monthly price range in pesos, for example 3000 to 4500.
  final int priceMin;
  final int priceMax;
  final List<String> tags;

  factory Property.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final location = d['location'] as GeoPoint?;
    return Property(
      id: doc.id,
      landlordId: d['landlordId'] as String,
      name: d['name'] as String? ?? '',
      description: d['description'] as String? ?? '',
      latitude: location?.latitude ?? 0,
      longitude: location?.longitude ?? 0,
      photos: List<String>.from(d['photos'] as List? ?? const []),
      priceMin: (d['priceMin'] as num?)?.toInt() ?? 0,
      priceMax: (d['priceMax'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(d['tags'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'landlordId': landlordId,
        'name': name,
        'description': description,
        'location': GeoPoint(latitude, longitude),
        'photos': photos,
        'priceMin': priceMin,
        'priceMax': priceMax,
        'tags': tags,
      };
}

/// "₱3,000–4,500" (or "₱3,500" when both are the same).
String formatPriceRange(int min, int max) {
  if (min == max) return '₱${formatPesos(min)}';
  return '₱${formatPesos(min)}–${formatPesos(max)}';
}

/// 4500 → "4,500".
String formatPesos(int amount) {
  final s = amount.toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

/// "3,000" or "₱ 3000" → 3000. Null if it isn't a whole number.
int? parsePesos(String text) => int.tryParse(text.replaceAll(RegExp(r'[₱,\s]'), ''));
