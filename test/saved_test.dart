import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boardmate/services/saved_service.dart';

void main() {
  test('Save and unsave: saved doc appears/disappears and the house count moves by 1', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('properties').doc('p1').set({'name': 'Neegy', 'saveCount': 0});
    final service = SavedService(db);

    await service.setSaved(userId: 'u1', propertyId: 'p1', saved: true);
    final doc = await db.collection('saved').doc('u1_p1').get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['userId'], 'u1');
    expect(doc.data()!['propertyId'], 'p1');
    expect((await db.collection('properties').doc('p1').get()).data()!['saveCount'], 1);
    expect(await service.watchIds('u1').first, ['p1']);
    expect(await service.watchIds('someone-else').first, isEmpty);

    await service.setSaved(userId: 'u1', propertyId: 'p1', saved: false);
    expect((await db.collection('saved').doc('u1_p1').get()).exists, isFalse);
    expect((await db.collection('properties').doc('p1').get()).data()!['saveCount'], 0);
    expect(await service.watchIds('u1').first, isEmpty);
  });
}
