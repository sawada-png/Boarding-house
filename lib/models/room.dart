import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType { bedspace, solo }

/// Ready-made "what's included" items a landlord can tap. They can also type their own.
const roomIncludedOptions = [
  'Bed',
  'Mattress',
  'Study table',
  'Chair',
  'Electric fan',
  'Aircon',
  'Cabinet',
  'Window',
];

/// A room inside a boarding house, saved in Firestore at rooms/{id}.
class Room {
  const Room({
    this.id = '',
    required this.propertyId,
    required this.landlordId,
    required this.name,
    required this.type,
    required this.monthlyPrice,
    this.capacity = 1,
    this.privateCr = false,
    this.available = true,
    this.included = const [],
    this.photos = const [],
    this.updatedAt,
  });

  /// Empty until it's saved the first time.
  final String id;
  final String propertyId;

  /// Copied from the property so the security rules can check the owner quickly.
  final String landlordId;

  /// "Room 1", "Room 2"...
  final String name;
  final RoomType type;

  /// How many people share a bedspace. Always 1 for a solo room.
  final int capacity;

  /// Pesos per month (per person for a bedspace).
  final int monthlyPrice;

  /// True for own CR, false for shared CR.
  final bool privateCr;
  final bool available;
  final List<String> included;
  final List<String> photos;

  /// When the landlord last saved this room. Null until the server sets it.
  final DateTime? updatedAt;

  /// "Bedspace for 2" or "Solo room".
  String get typeLabel => type == RoomType.solo ? 'Solo room' : 'Bedspace for $capacity';

  /// "Bedspace for 2 · own CR · study table, electric fan"
  String get summary => [
        typeLabel,
        privateCr ? 'own CR' : 'shared CR',
        if (included.isNotEmpty) included.map((i) => i.toLowerCase()).join(', '),
      ].join(' · ');

  factory Room.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Room(
      id: doc.id,
      propertyId: d['propertyId'] as String,
      landlordId: d['landlordId'] as String,
      name: d['name'] as String? ?? '',
      type: d['type'] == 'solo' ? RoomType.solo : RoomType.bedspace,
      capacity: (d['capacity'] as num?)?.toInt() ?? 1,
      monthlyPrice: (d['monthlyPrice'] as num?)?.toInt() ?? 0,
      privateCr: d['crType'] == 'private',
      available: d['available'] as bool? ?? true,
      included: List<String>.from(d['included'] as List? ?? const []),
      photos: List<String>.from(d['photos'] as List? ?? const []),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'propertyId': propertyId,
        'landlordId': landlordId,
        'name': name,
        'type': type.name,
        'capacity': type == RoomType.solo ? 1 : capacity,
        'monthlyPrice': monthlyPrice,
        'crType': privateCr ? 'private' : 'shared',
        'available': available,
        'included': included,
        'photos': photos,
      };
}

/// Sorts "Room 2" before "Room 10" (plain text sorting would put 10 first).
int compareRoomNames(String a, String b) {
  final numberA = int.tryParse(RegExp(r'\d+').firstMatch(a)?.group(0) ?? '');
  final numberB = int.tryParse(RegExp(r'\d+').firstMatch(b)?.group(0) ?? '');
  if (numberA != null && numberB != null && numberA != numberB) return numberA.compareTo(numberB);
  return a.compareTo(b);
}

/// propertyId → how many of its rooms are available.
/// Boarding houses with no rooms yet are left out.
Map<String, int> countAvailableRooms(Iterable<Room> rooms) {
  final counts = <String, int>{};
  for (final room in rooms) {
    counts[room.propertyId] = (counts[room.propertyId] ?? 0) + (room.available ? 1 : 0);
  }
  return counts;
}
