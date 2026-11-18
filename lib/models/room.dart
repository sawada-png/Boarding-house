import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType { bedspace, solo }

/// Which floor a room is on, for the Room Map.
enum RoomFloor {
  ground('GF', 'Ground'),
  second('2F', '2nd floor'),
  third('3F', '3rd floor');

  const RoomFloor(this.short, this.label);

  /// "2F" on the Room Map.
  final String short;

  /// "2nd floor" on the room form.
  final String label;
}

/// Electricity: part of the rent, or the room has its own meter (landlord gives an estimate).
enum ElectricityCost { included, ownMeter }

/// Water: part of the rent, or paid separately.
enum WaterCost { included, separate }

/// Wi-Fi: part of the rent, a fixed monthly price, or no Wi-Fi.
enum WifiCost { included, paid, none }

/// Usual move-in terms a landlord can pick.
const moveInOptions = [
  '1 month deposit + 1 month advance',
  '1 month advance only',
  '2 months deposit + 1 month advance',
  'No deposit',
];

/// Ready-made "what's included" items a landlord can tap. They can also type their own.
const roomIncludedOptions = ['Bed', 'Mattress', 'Study table', 'Chair', 'Electric fan', 'Aircon', 'Cabinet', 'Window'];

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
    this.floor = RoomFloor.ground,
    this.updatedAt,
    this.openedAt,
    this.electricity = ElectricityCost.included,
    this.electricityEstimate = 0,
    this.water = WaterCost.included,
    this.wifi = WifiCost.none,
    this.wifiPrice = 0,
    this.moveIn = '1 month deposit + 1 month advance',
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

  final RoomFloor floor;

  /// When the room last became open (added as open, or switched from taken). Null if unknown.
  final DateTime? openedAt;

  /// When the landlord last saved this room. Null until the server sets it.
  final DateTime? updatedAt;

  // Bills. Rooms saved before these existed read as: electricity and water included, no Wi-Fi.
  final ElectricityCost electricity;

  /// Landlord's guess of the monthly electric bill when the room has its own meter.
  final int electricityEstimate;
  final WaterCost water;
  final WifiCost wifi;

  /// Monthly Wi-Fi price when [wifi] is paid.
  final int wifiPrice;

  /// "1 month deposit + 1 month advance"
  final String moveIn;

  /// Rent plus the bills we know: "About ₱4,050 /mo". Separate water has no amount, so it isn't added.
  int get estimatedMonthly =>
      monthlyPrice +
      (electricity == ElectricityCost.ownMeter ? electricityEstimate : 0) +
      (wifi == WifiCost.paid ? wifiPrice : 0);

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
      openedAt: (d['openedAt'] as Timestamp?)?.toDate(),
      floor: RoomFloor.values.asNameMap()[d['floor']] ?? RoomFloor.ground,
      electricity: ElectricityCost.values.asNameMap()[d['electricity']] ?? ElectricityCost.included,
      electricityEstimate: (d['electricityEstimate'] as num?)?.toInt() ?? 0,
      water: WaterCost.values.asNameMap()[d['water']] ?? WaterCost.included,
      wifi: WifiCost.values.asNameMap()[d['wifi']] ?? WifiCost.none,
      wifiPrice: (d['wifiPrice'] as num?)?.toInt() ?? 0,
      moveIn: d['moveIn'] as String? ?? '1 month deposit + 1 month advance',
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
    'floor': floor.name,
    'electricity': electricity.name,
    'electricityEstimate': electricity == ElectricityCost.ownMeter ? electricityEstimate : 0,
    'water': water.name,
    'wifi': wifi.name,
    'wifiPrice': wifi == WifiCost.paid ? wifiPrice : 0,
    'moveIn': moveIn,
  };
}

/// Sorts "Room 2" before "Room 10" (plain text sorting would put 10 first).
int compareRoomNames(String a, String b) {
  final numberA = int.tryParse(RegExp(r'\d+').firstMatch(a)?.group(0) ?? '');
  final numberB = int.tryParse(RegExp(r'\d+').firstMatch(b)?.group(0) ?? '');
  if (numberA != null && numberB != null && numberA != numberB) return numberA.compareTo(numberB);
  return a.compareTo(b);
}
