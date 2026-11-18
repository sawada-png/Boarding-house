import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';

/// Rounded box with diagonal gray stripes: how "taken" rooms look.
class StripedBox extends StatelessWidget {
  const StripedBox({super.key, this.radius = 12, this.stripe = 6, this.child});

  final double radius;

  /// Width of one stripe. 6 on room tiles, 3 on tiny legend squares.
  final double stripe;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(painter: _StripePainter(stripe), child: child),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.stripe);

  final double stripe;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.stripeLight);
    final paint = Paint()
      ..color = AppColors.stripeDark
      ..strokeWidth = stripe;
    // Lines going up-right, one every 2 stripes (dark, light, dark...).
    final step = stripe * 2 * 1.414;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.stripe != stripe;
}
