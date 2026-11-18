import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/picked_photo.dart';
import '../models/room.dart';
import 'storage_service.dart';

/// Saves and reads rooms in Firestore (rooms/{id}).
class RoomService {
  final _rooms = FirebaseFirestore.instance.collection('rooms');
  final _storage = StorageService();

  /// Rooms of one boarding house, sorted Room 1, Room 2, ... Room 10.
  Stream<List<Room>> watchForProperty(String propertyId) => _rooms
      .where('propertyId', isEqualTo: propertyId)
      .snapshots()
      .map((snap) => snap.docs.map(Room.fromDoc).toList()
        ..sort((a, b) => compareRoomNames(a.name, b.name)));

  /// Every room, used to count available rooms on the student home list.
  Stream<List<Room>> watchAll() =>
      _rooms.snapshots().map((snap) => snap.docs.map(Room.fromDoc).toList());

  /// Adds a new room (when [room].id is empty) or updates an existing one. Uploads new photos first.
  Future<void> save(Room room, List<PickedPhoto> photos) async {
    final isNew = room.id.isEmpty;
    final doc = isNew ? _rooms.doc() : _rooms.doc(room.id);

    final urls = await _storage.uploadAll(
      photos,
      'boardmate/landlords/${room.landlordId}/rooms/${doc.id}',
    );

    await doc.set({
      ...room.toMap(),
      'photos': urls,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> delete(String roomId) => _rooms.doc(roomId).delete();
}
