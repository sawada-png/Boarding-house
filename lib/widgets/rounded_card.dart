import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// White card with big rounded corners and a soft shadow.
class RoundedCard extends StatelessWidget {
  const RoundedCard({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.shadow = true,
    this.color = AppColors.card,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool shadow;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? const [
                BoxShadow(color: Color(0x0A0F1D20), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(color: Color(0x140F1D20), blurRadius: 32, offset: Offset(0, 12)),
              ]
            : null,
      ),
      child: child,
    );
  }
}
