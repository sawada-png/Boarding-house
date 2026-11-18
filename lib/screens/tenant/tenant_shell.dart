import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/app_user.dart';
import '../../widgets/bm_tab_scaffold.dart';
import '../shared/placeholder_tab.dart';
import '../shared/profile_tab.dart';
import 'home_tab.dart';

/// Student mode: the four tabs of the floating tab bar.
class TenantShell extends StatelessWidget {
  const TenantShell({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    return BmTabScaffold(
      tabs: [
        BmTab(icon: CupertinoIcons.compass, label: 'Explore', builder: (_) => HomeTab(profile: profile)),
        BmTab(
          icon: CupertinoIcons.heart,
          label: 'Saved',
          builder: (_) => const PlaceholderTab(title: 'Saved', comingIn: 'Week 2'),
        ),
        BmTab(
          icon: CupertinoIcons.chat_bubble,
          label: 'Messages',
          builder: (_) => const PlaceholderTab(title: 'Messages', comingIn: 'Week 3'),
        ),
        BmTab(icon: CupertinoIcons.person, label: 'Profile', builder: (_) => ProfileTab(profile: profile)),
      ],
    );
  }
}
