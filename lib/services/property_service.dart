import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/picked_photo.dart';
import '../models/property.dart';
import 'storage_service.dart';

/// Saves and reads boarding houses in Firestore (properties/{id}).
class PropertyService {
  final _properties = FirebaseFirestore.instance.collection('properties');
  final _storage = StorageService();

  /// All boarding houses owned by [landlordId].
  Stream<List<Property>> watchMine(String landlordId) => _properties
      .where('landlordId', isEqualTo: landlordId)
      .snapshots()
      .map((snap) => snap.docs.map(Property.fromDoc).toList());

  /// Adds a new boarding house (when [property].id is empty) or updates an existing one.
  /// Uploads new photos first, then saves.
  Future<void> save(Property property, List<PickedPhoto> photos) async {
    final isNew = property.id.isEmpty;
    final doc = isNew ? _properties.doc() : _properties.doc(property.id);

    final urls = await _storage.uploadAll(
      photos,
      'boardmate/landlords/${property.landlordId}/properties/${doc.id}',
    );

    await doc.set({
      ...property.toMap(),
      'photos': urls,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Deletes the boarding house and all its rooms together (all or nothing).
  Future<void> delete(Property property) async {
    final rooms = await FirebaseFirestore.instance
        .collection('rooms')
        .where('propertyId', isEqualTo: property.id)
        .where('landlordId', isEqualTo: property.landlordId)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final room in rooms.docs) {
      batch.delete(room.reference);
    }
    batch.delete(_properties.doc(property.id));
    await batch.commit();
  }
}
