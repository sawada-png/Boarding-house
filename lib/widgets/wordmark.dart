import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// "boardmate" logo text, with "mate" in lagoon.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'board',
        style: AppText.section.copyWith(fontSize: size, letterSpacing: -0.5),
        children: const [
          TextSpan(
            text: 'mate',
            style: TextStyle(color: AppColors.lagoon),
          ),
        ],
      ),
      semanticsLabel: 'BoardMate',
    );
  }
}
