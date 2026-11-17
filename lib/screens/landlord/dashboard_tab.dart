import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/app_user.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import 'property_form_screen.dart';

/// Landlord home: their boarding house, or a button to add one.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.profile});

  final AppUser profile;

  void _openForm(BuildContext context, [Property? existing]) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => PropertyFormScreen(landlordId: profile.uid, existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Property>>(
          stream: PropertyService().watchMine(profile.uid),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text("Couldn't load your listing.", style: AppText.secondary));
            }
            if (!snap.hasData) return const Center(child: CupertinoActivityIndicator());

            // shortcut: shows the first boarding house only; add a switcher if a landlord owns several.
            final property = snap.data!.isEmpty ? null : snap.data!.first;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                Text(
                  'LANDLORD MODE',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: AppColors.tealDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property?.name ?? 'Hi, ${profile.name.split(' ').first}!',
                  style: AppText.largeTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 20),
                if (property == null)
                  _EmptyState(onAdd: () => _openForm(context))
                else ...[
                  Text('How students see it', style: AppText.secondary),
                  const SizedBox(height: 8),
                  ListingCard(
                    name: property.name,
                    subtitle: property.tags.isEmpty ? 'Puerto Princesa' : property.tags.take(3).join(' · '),
                    priceText: formatPriceRange(property.priceMin, property.priceMax),
                    photoUrl: property.photos.isEmpty ? null : property.photos.first,
                    onTap: () => _openForm(context, property),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Edit details',
                    secondary: true,
                    icon: CupertinoIcons.pencil,
                    onPressed: () => _openForm(context, property),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.house, color: AppColors.teal, size: 30),
          ),
          const SizedBox(height: 16),
          Text('List your boarding house', style: AppText.cardTitle.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
          Text(
            'Add photos, the location and your prices. Students near campus will find you here.',
            textAlign: TextAlign.center,
            style: AppText.secondary.copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Add boarding house', icon: CupertinoIcons.add, onPressed: onAdd),
        ],
      ),
    );
  }
}
