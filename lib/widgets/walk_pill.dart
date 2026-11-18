import 'package:cupertino_ui/cupertino_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// White pill on top of photos, like "6 min walk to PSU".
class WalkPill extends StatelessWidget {
  const WalkPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 14, height: 14, child: CustomPaint(painter: WalkerPainter())),
          const SizedBox(width: 6),
          Text(text, style: AppText.label.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

/// Small walking person (Cupertino icons has none), drawn from the mockup's icon.
class WalkerPainter extends CustomPainter {
  const WalkerPainter({this.color = AppColors.ink});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(Offset(13 * s, 4 * s), 2 * s, paint);
    canvas.drawPath(
      Path()
        ..moveTo(9 * s, 21 * s)
        ..lineTo(12 * s, 14 * s)
        ..lineTo(15 * s, 17 * s)
        ..lineTo(15 * s, 21 * s)
        ..moveTo(7 * s, 12 * s)
        ..lineTo(10 * s, 8 * s)
        ..lineTo(14 * s, 9 * s)
        ..lineTo(17 * s, 12 * s),
      paint,
    );
  }

  @override
  bool shouldRepaint(WalkerPainter old) => old.color != color;
}
