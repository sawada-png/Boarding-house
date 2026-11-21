import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../shared/messages_tab.dart';
import '../shared/profile_tab.dart';
import 'home_tab.dart';
import 'saved_tab.dart';

/// Student mode: the four tabs of the floating tab bar.
class TenantShell extends StatelessWidget {
  const TenantShell({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return BmTabScaffold(
      tabs: [
        BmTab(
          icon: CupertinoIcons.compass,
          label: 'Explore',
          builder: (_) => HomeTab(profile: profile),
        ),
        BmTab(
          icon: CupertinoIcons.heart,
          label: 'Saved',
          builder: (_) => SavedTab(profile: profile),
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
