import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// Round white back button, like the one on the listing mockup.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: const Icon(CupertinoIcons.chevron_left, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}
