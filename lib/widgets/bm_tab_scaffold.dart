import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// One tab in the bottom bar.
class BmTab {
  const BmTab({required this.icon, required this.label, required this.builder});

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// Screen with the white bottom tab bar. Used by student mode and landlord mode.
class BmTabScaffold extends StatelessWidget {
  const BmTabScaffold({super.key, required this.tabs});

  final List<BmTab> tabs;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.teal,
        inactiveColor: AppColors.textSecondary,
        backgroundColor: const Color(0xEBFFFFFF),
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        items: [
          for (final tab in tabs) BottomNavigationBarItem(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
      tabBuilder: (context, index) => CupertinoTabView(builder: tabs[index].builder),
    );
  }
}
