import 'package:cloud_firestore/cloud_firestore.dart';

import 'room.dart';

/// pending: the landlord added the student, waiting for the student to confirm.
/// active: both confirmed, the student lives there. ended: moved out. declined: the student said no.
enum StayStatus { pending, active, ended, declined }

/// A student living in a room, saved at stays/{id}. Confirmed by both sides, so it can back a review.
class Stay {
  const Stay({
    this.id = '',
    required this.studentId,
    required this.studentName,
    required this.landlordId,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomName,
    this.status = StayStatus.pending,
    this.movedInAt,
    this.movedOutAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String landlordId;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomName;
  final StayStatus status;
  final DateTime? movedInAt;
  final DateTime? movedOutAt;

  /// Both sides confirmed: the student may review the house.
  bool get verified => status == StayStatus.active || status == StayStatus.ended;

  /// Still uses a bed in the room.
  bool get holdsBed => status == StayStatus.pending || status == StayStatus.active;

  factory Stay.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Stay(
      id: doc.id,
      studentId: d['studentId'] as String? ?? '',
      studentName: d['studentName'] as String? ?? '',
      landlordId: d['landlordId'] as String? ?? '',
      propertyId: d['propertyId'] as String? ?? '',
      propertyName: d['propertyName'] as String? ?? '',
      roomId: d['roomId'] as String? ?? '',
      roomName: d['roomName'] as String? ?? '',
      status: StayStatus.values.asNameMap()[d['status']] ?? StayStatus.pending,
      movedInAt: (d['movedInAt'] as Timestamp?)?.toDate(),
      movedOutAt: (d['movedOutAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toNewMap() => {
    'studentId': studentId,
    'studentName': studentName,
    'landlordId': landlordId,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'roomId': roomId,
    'roomName': roomName,
    'status': StayStatus.pending.name,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// True if one more tenant fills the room (a solo room, or the last bed of a bedspace).
bool fillsRoom(Room room, List<Stay> stays) =>
    stays.where((s) => s.roomId == room.id && s.holdsBed).length + 1 >= room.capacity;
