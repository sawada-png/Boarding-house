import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/picked_photo.dart';
import '../models/room.dart';
import 'storage_service.dart';

/// Saves and reads rooms in Firestore (rooms/{id}).
class RoomService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');
  final _storage = StorageService();

  /// Rooms of one boarding house, sorted Room 1, Room 2, ... Room 10.
  Stream<List<Room>> watchForProperty(String propertyId) => _rooms
      .where('propertyId', isEqualTo: propertyId)
      .snapshots()
      .map((snap) => snap.docs.map(Room.fromDoc).toList()..sort((a, b) => compareRoomNames(a.name, b.name)));

  /// Every room, used to count open rooms on the student home list.
  Stream<List<Room>> watchAll() => _rooms.snapshots().map((snap) => snap.docs.map(Room.fromDoc).toList());

  /// Adds a new room (when [room].id is empty) or updates an existing one. Uploads new photos first.
  /// [wasOpen] is whether the room was open before this save, so "opened at" is only set when it opens.
  Future<void> save(Room room, List<PickedPhoto> photos, {bool wasOpen = false}) async {
    final isNew = room.id.isEmpty;
    final doc = isNew ? _rooms.doc() : _rooms.doc(room.id);

    final urls = await _storage.uploadAll(photos, 'boardmate/landlords/${room.landlordId}/rooms/${doc.id}');

    final batch = _db.batch()
      ..set(doc, {
        ...room.toMap(),
        'photos': urls,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
        if (room.available && !wasOpen) 'openedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    _confirm(batch, room.propertyId);
    await batch.commit();
  }

  /// One-tap switch from the landlord's Room Map: open ↔ taken.
  Future<void> setOpen(Room room, bool open) {
    final batch = _db.batch()
      ..update(_rooms.doc(room.id), {
        'available': open,
        'updatedAt': FieldValue.serverTimestamp(),
        if (open) 'openedAt': FieldValue.serverTimestamp(),
      });
    _confirm(batch, room.propertyId);
    return batch.commit();
  }

  /// Weekly check "Yes, still open": marks the room as checked without changing it.
  Future<void> stillOpen(Room room) {
    final batch = _db.batch()..update(_rooms.doc(room.id), {'updatedAt': FieldValue.serverTimestamp()});
    _confirm(batch, room.propertyId);
    return batch.commit();
  }

  /// Any room change by the landlord counts as "rooms checked" on the house.
  void _confirm(WriteBatch batch, String propertyId) =>
      batch.update(_db.collection('properties').doc(propertyId), {'lastConfirmedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String roomId) => _rooms.doc(roomId).delete();
}
