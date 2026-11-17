import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// White card with rounded corners and a soft shadow.
class RoundedCard extends StatelessWidget {
  const RoundedCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
              ]
            : null,
      ),
      child: child,
    );
  }
}
