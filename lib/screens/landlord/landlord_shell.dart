import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../services/landlord_service.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../shared/placeholder_tab.dart';
import '../shared/profile_tab.dart';
import 'dashboard_tab.dart';

/// Landlord mode: the four bottom tabs from the landlord mockup.
class LandlordShell extends StatefulWidget {
  const LandlordShell({super.key, required this.profile});

  final AppUser profile;

  @override
  State<LandlordShell> createState() => _LandlordShellState();
}

class _LandlordShellState extends State<LandlordShell> {
  AppUser get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    // Students see this name on the house page. Failing is harmless: it retries next time.
    LandlordService().publish(profile.uid, profile.name).ignore();
  }

  @override
  Widget build(BuildContext context) {
    return BmTabScaffold(
      tabs: [
        BmTab(
          icon: CupertinoIcons.house,
          label: 'House',
          builder: (_) => DashboardTab(profile: profile),
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
