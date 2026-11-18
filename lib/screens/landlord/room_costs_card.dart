import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:google_fonts/google_fonts.dart';

import '../../models/property.dart' show formatPesos;
import '../../models/room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// White card on the room form (design-2.0/8-roomform): rent, electricity, water, Wi-Fi and move-in.
/// The form keeps the values; this card only shows them and reports taps.
class RoomCostsCard extends StatelessWidget {
  const RoomCostsCard({
    super.key,
    required this.perPerson,
    required this.rent,
    required this.electricity,
    required this.electricityEstimate,
    required this.water,
    required this.wifi,
    required this.wifiPrice,
    required this.moveIn,
    required this.onElectricity,
    required this.onWater,
    required this.onWifi,
    required this.onMoveIn,
  });

  /// Bedspace: "Rent per person". Solo: "Rent per month".
  final bool perPerson;
  final TextEditingController rent;
  final ElectricityCost electricity;
  final TextEditingController electricityEstimate;
  final WaterCost water;
  final WifiCost wifi;
  final TextEditingController wifiPrice;
  final String moveIn;
  final ValueChanged<ElectricityCost> onElectricity;
  final ValueChanged<WaterCost> onWater;
  final ValueChanged<WifiCost> onWifi;
  final ValueChanged<String> onMoveIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          _Line(
            label: perPerson ? 'Rent per person' : 'Rent per month',
            child: _PesoField(controller: rent, hint: '3,500'),
          ),
          _Line(
            label: 'Electricity',
            child: _Options(
              labels: const ['Included', 'Own meter'],
              selected: electricity.index,
              onTap: (i) => onElectricity(ElectricityCost.values[i]),
            ),
          ),
          if (electricity == ElectricityCost.ownMeter)
            _Line(
              label: 'About how much a month?',
              small: true,
              child: _PesoField(controller: electricityEstimate, hint: '400'),
            ),
          _Line(
            label: 'Water',
            child: _Options(
              labels: const ['Included', 'Separate'],
              selected: water.index,
              onTap: (i) => onWater(WaterCost.values[i]),
            ),
          ),
          _Line(
            label: 'Wi-Fi',
            child: _Options(
              labels: const ['Included', 'Paid', 'None'],
              selected: wifi.index,
              onTap: (i) => onWifi(WifiCost.values[i]),
            ),
          ),
          if (wifi == WifiCost.paid)
            _Line(
              label: 'Wi-Fi price a month',
              small: true,
              child: _PesoField(controller: wifiPrice, hint: '150'),
            ),
          _Line(
            label: 'Move-in',
            last: true,
            child: _MoveInButton(value: moveIn, onPicked: onMoveIn),
          ),
        ],
      ),
    );
  }
}

/// Lagoon banner under the card: "Students will see  About ₱4,050 /mo".
class StudentsWillSee extends StatelessWidget {
  const StudentsWillSee({super.key, required this.amount});

  /// Null while the rent is still empty.
  final int? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.lagoonLight, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Text('Students will see', style: AppText.small.copyWith(fontSize: 13, color: AppColors.lagoonDark)),
          ),
          Text(
            amount == null ? 'Type the rent' : 'About ₱${formatPesos(amount!)} /mo',
            style: AppText.section.copyWith(fontSize: 20, color: AppColors.lagoonDark),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.child, this.last = false, this.small = false});

  final String label;
  final Widget child;
  final bool last;

  /// Follow-up line like "About how much a month?".
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFEDF0EF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: small
                  ? AppText.secondary.copyWith(fontSize: 14)
                  : AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}

/// Small option pills; the picked one is ink.
class _Options extends StatelessWidget {
  const _Options({required this.labels, required this.selected, required this.onTap});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Semantics(
            button: true,
            selected: i == selected,
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.ink : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: i == selected ? FontWeight.w600 : FontWeight.w500,
                    color: i == selected ? AppColors.card : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Right-aligned "₱ 3,500" number box.
class _PesoField extends StatelessWidget {
  const _PesoField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: CupertinoTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
        placeholder: hint,
        textAlign: TextAlign.right,
        prefix: Text('₱', style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        style: AppText.body.copyWith(fontWeight: FontWeight.w700),
        decoration: const BoxDecoration(),
      ),
    );
  }
}

class _MoveInButton extends StatelessWidget {
  const _MoveInButton({required this.value, required this.onPicked});

  final String value;
  final ValueChanged<String> onPicked;

  Future<void> _pick(BuildContext context) async {
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.stripeDark, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Move-in terms', style: AppText.title.copyWith(fontSize: 22)),
              const SizedBox(height: 12),
              for (final option in moveInOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, option),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: option == value ? AppColors.lagoon : AppColors.card, width: 2),
                      ),
                      child: Text(option, style: AppText.label.copyWith(fontSize: 15)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => _pick(context),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  shortMoveIn(value),
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_down, size: 13, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

/// "1 month deposit + 1 month advance" → "1 deposit + 1 advance" so it fits the row.
String shortMoveIn(String terms) => terms.replaceAll(' months ', ' ').replaceAll(' month ', ' ');
