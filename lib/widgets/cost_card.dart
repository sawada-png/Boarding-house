import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/property.dart' show formatPesos;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One line on the cost card, like "Electricity · own meter   ~₱600".
class CostLine {
  const CostLine(this.label, this.amount, {this.estimate = false});

  /// Shown as "included" in green; adds nothing to the total.
  const CostLine.included(this.label)
      : amount = null,
        estimate = false;

  final String label;

  /// Pesos per month. Null = included.
  final int? amount;

  /// Adds "~" in front: the landlord's guess, like the electric bill.
  final bool estimate;
}

/// Dark card: rent + electricity + water + Wi-Fi = "About ₱X /mo", plus move-in terms.
class CostCard extends StatelessWidget {
  const CostCard({super.key, required this.lines, this.moveIn, this.title = 'Real monthly cost'});

  final List<CostLine> lines;

  /// "1 month deposit + 1 month advance"
  final String? moveIn;
  final String title;

  static int totalOf(List<CostLine> lines) => lines.fold(0, (sum, l) => sum + (l.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    final lineStyle = GoogleFonts.inter(fontSize: 14, color: AppColors.onInk);
    final muted = GoogleFonts.inter(fontSize: 12, color: AppColors.onInkMuted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(title, style: AppText.section.copyWith(fontSize: 17, color: AppColors.card))),
              Text('estimate by owner', style: muted),
            ],
          ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(child: Text(line.label, style: lineStyle)),
                  Text(
                    line.amount == null
                        ? 'included'
                        : '${line.estimate ? '~' : ''}₱${formatPesos(line.amount!)}',
                    style: line.amount == null ? lineStyle.copyWith(color: AppColors.onInkGood) : lineStyle,
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2C3A3D)))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text('About',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.card)),
                ),
                Text.rich(TextSpan(
                  text: '₱${formatPesos(totalOf(lines))}',
                  style: AppText.title.copyWith(color: AppColors.card),
                  children: [
                    TextSpan(
                      text: ' /mo',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onInkMuted),
                    ),
                  ],
                )),
              ],
            ),
          ),
          if (moveIn != null) ...[
            const SizedBox(height: 10),
            Text('Move-in: $moveIn', style: muted),
          ],
        ],
      ),
    );
  }
}
