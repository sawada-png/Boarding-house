import 'dart:ui' show PathMetric;

import 'package:cupertino_ui/cupertino_ui.dart';

/// Box with a dashed rounded outline: shared spaces and empty Room Map slots.
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, this.child, this.radius = 12});

  final Widget? child;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DashedPainter(radius), child: child);
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.75);
    final paint = Paint()
      ..color = const Color(0xFFC9D3D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final PathMetric metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 8) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.radius != radius;
}
