import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/property.dart';
import '../../models/school.dart';
import '../../services/saved_service.dart';
import '../../widgets/listing_card.dart';
import '../shared/dialogs.dart';
import 'home_logic.dart';
import 'listing_screen.dart';

/// A boarding house card for Home and Saved: fills in the walk pill, price and room dots,
/// opens the house page on tap, and saves/unsaves with the heart.
class HouseCard extends StatelessWidget {
  const HouseCard({
    super.key,
    required this.property,
    required this.rooms,
    required this.school,
    required this.userId,
    required this.saved,
  });

  final Property property;

  /// Null if the house has no rooms yet.
  final HouseRooms? rooms;
  final School? school;
  final String userId;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final r = rooms;
    final s = school;
    return ListingCard(
      name: p.name,
      // shortcut: reviews come in Week 3, so every house is "New" for now.
      subtitle: 'New · ${p.area.isEmpty ? 'Puerto Princesa' : p.area}',
      fromPrice: '₱${formatPesos(r?.cheapestOpen ?? p.priceMin)}',
      photoUrl: p.photos.isEmpty ? null : p.photos.first,
      walkText: s == null ? null : walkText(distanceTo(s, p), s),
      openRooms: r?.open ?? 0,
      totalRooms: r?.total ?? 0,
      checkedAt: lastChecked(p, r),
      saved: saved,
      onSave: () => toggleSaved(context, userId: userId, propertyId: p.id, saved: !saved),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (_) => ListingScreen(property: p, school: s, userId: userId),
        ),
      ),
    );
  }
}

/// Saves or unsaves a house, with a friendly popup if it fails.
Future<void> toggleSaved(
  BuildContext context, {
  required String userId,
  required String propertyId,
  required bool saved,
}) async {
  try {
    await SavedService().setSaved(userId: userId, propertyId: propertyId, saved: saved);
  } catch (_) {
    if (context.mounted) {
      await showError(context, "Couldn't update your saved list. Check your internet and try again.");
    }
  }
}
