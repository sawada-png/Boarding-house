import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_text_styles.dart';

/// Temporary tab for screens that come in later weeks.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.title, required this.comingIn});

  final String title;
  final String comingIn;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.largeTitle),
              const SizedBox(height: 8),
              Text('Coming in $comingIn', style: AppText.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
