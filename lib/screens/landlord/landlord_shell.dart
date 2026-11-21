import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../services/landlord_service.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../shared/messages_tab.dart';
import '../shared/profile_tab.dart';
import 'dashboard_tab.dart';
import 'tenants_tab.dart';

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
    // Students see this name on the house page and can call the phone from chat. Failing is harmless: it retries next time.
    LandlordService().publish(profile.uid, profile.name, profile.phone).ignore();
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
          builder: (_) => TenantsTab(profile: profile),
        ),
        BmTab(
          icon: CupertinoIcons.chat_bubble,
          label: 'Messages',
          builder: (_) => MessagesTab(profile: profile),
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
