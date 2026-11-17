import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../shared/placeholder_tab.dart';
import '../shared/profile_tab.dart';

/// Landlord mode: the four bottom tabs from the landlord mockup.
class LandlordShell extends StatelessWidget {
  const LandlordShell({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return BmTabScaffold(
      tabs: [
        BmTab(
          icon: CupertinoIcons.square_grid_2x2,
          label: 'Dashboard',
          builder: (_) => const PlaceholderTab(title: 'Dashboard', comingIn: 'Step 5'),
        ),
        BmTab(
          icon: CupertinoIcons.person_2,
          label: 'Tenants',
          builder: (_) => const PlaceholderTab(title: 'Tenants', comingIn: 'Week 3'),
        ),
        BmTab(
          icon: CupertinoIcons.chat_bubble,
          label: 'Messages',
          builder: (_) => const PlaceholderTab(title: 'Messages', comingIn: 'Week 3'),
        ),
        BmTab(
          icon: CupertinoIcons.person,
          label: 'Profile',
          builder: (_) => ProfileTab(profile: profile),
        ),
      ],
    );
  }
}
