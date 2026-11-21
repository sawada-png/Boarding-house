import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/room.dart';
import '../models/stay.dart';

/// Move in / move out at stays/{id}. The landlord adds a tenant, the student confirms.
class StayService {
  StayService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _stays => _db.collection('stays');

  Stream<List<Stay>> watchForLandlord(String uid) =>
      _stays.where('landlordId', isEqualTo: uid).snapshots().map((s) => s.docs.map(Stay.fromDoc).toList());

  Stream<List<Stay>> watchForStudent(String uid) =>
      _stays.where('studentId', isEqualTo: uid).snapshots().map((s) => s.docs.map(Stay.fromDoc).toList());

  /// Landlord: adds a tenant. If that fills the room, the room becomes taken in the same write.
  Future<void> add(Stay stay, Room room, {required bool fillsRoom}) {
    final batch = _db.batch()..set(_stays.doc(), stay.toNewMap());
    if (fillsRoom && room.available) _setRoomOpen(batch, room, false);
    return batch.commit();
  }

  /// Student: "Yes, I moved in" (true) or "Not me" (false).
  Future<void> answer(Stay stay, bool movedIn) => _stays.doc(stay.id).update({
    'status': (movedIn ? StayStatus.active : StayStatus.declined).name,
    if (movedIn) 'movedInAt': FieldValue.serverTimestamp(),
  });

  /// Landlord: the tenant moved out (or never came). Opens the room again.
  Future<void> moveOut(Stay stay, Room? room) {
    final batch = _db.batch()
      ..update(_stays.doc(stay.id), {'status': StayStatus.ended.name, 'movedOutAt': FieldValue.serverTimestamp()});
    if (room != null && !room.available) _setRoomOpen(batch, room, true);
    return batch.commit();
  }

  void _setRoomOpen(WriteBatch batch, Room room, bool open) {
    batch
      ..update(_db.collection('rooms').doc(room.id), {
        'available': open,
        'updatedAt': FieldValue.serverTimestamp(),
        if (open) 'openedAt': FieldValue.serverTimestamp(),
      })
      ..update(_db.collection('properties').doc(room.propertyId), {'lastConfirmedAt': FieldValue.serverTimestamp()});
  }
}
