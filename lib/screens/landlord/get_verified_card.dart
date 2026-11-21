import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../services/landlord_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';

/// What a landlord sends to get verified. Staff check them by hand and turn on the badge in Firebase.
const verifySteps = [
  'A government ID. The PhilSys National ID (PhilID or ePhilID) is best: we scan its QR code.',
  'A selfie of you holding that ID.',
  "Your Mayor's / Business Permit or a Barangay Clearance for the boarding house.",
];

/// Landlord profile: "Verified owner" if checked, otherwise how to get the badge.
class GetVerifiedCard extends StatelessWidget {
  const GetVerifiedCard({super.key, required this.uid, required this.name, this.info});

  final String uid;
  final String name;

  /// Only set in tests.
  final Stream<LandlordInfo?>? info;

  void _email() => launchUrl(
    Uri(
      scheme: 'mailto',
      path: verifyEmail,
      query:
          'subject=${Uri.encodeComponent('Verify my boarding house · $name')}'
          '&body=${Uri.encodeComponent('Hi BoardMate! Attached: my ID, a selfie with it, and my permit.\nAccount: $uid')}',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LandlordInfo?>(
      stream: info ?? LandlordService().watch(uid),
      builder: (context, snap) {
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) return const SizedBox();
        if (snap.data?.verified ?? false) {
          return RoundedCard(
            shadow: false,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_shield_fill, color: AppColors.lagoon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verified owner', style: AppText.section),
                      Text('Students see this badge on your house.', style: AppText.secondary),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return RoundedCard(
          shadow: false,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.checkmark_shield, color: AppColors.lagoon, size: 24),
                  const SizedBox(width: 8),
                  Text('Get verified', style: AppText.section),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Students trust a "Verified owner" more. Send BoardMate these 3 things:',
                style: AppText.secondary.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < verifySteps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.lagoonLight, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: AppText.small.copyWith(color: AppColors.lagoonDark)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(verifySteps[i], style: AppText.body.copyWith(fontSize: 14, height: 1.4))),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'We check them by hand, turn on your badge, then delete the photos. '
                'Never post your ID in a chat or a listing.',
                style: AppText.secondary.copyWith(fontSize: 13, height: 1.4),
              ),
              if (verifyEmail.isNotEmpty) ...[
                const SizedBox(height: 14),
                PrimaryButton(label: 'Email my documents', icon: CupertinoIcons.mail, onPressed: _email),
              ],
            ],
          ),
        );
      },
    );
  }
}
