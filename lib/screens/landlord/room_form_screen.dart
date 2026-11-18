import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/picked_photo.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/close_circle_button.dart';
import '../../widgets/delete_text_button.dart';
import '../../widgets/form_section_label.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/photo_picker_grid.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/segmented_pills.dart';
import '../../widgets/tag_chip.dart';
import '../shared/dialogs.dart';
import 'room_costs_card.dart';

/// Add a room to a boarding house, or edit one when [existing] is given (design-2.0/8-roomform).
class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({super.key, required this.property, this.existing, this.suggestedName = 'Room 1'});

  final Property property;
  final Room? existing;

  /// Pre-filled name for a new room, like "Room 4".
  final String suggestedName;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  late final Room? _old = widget.existing;
  late final _name = TextEditingController(text: _old?.name ?? widget.suggestedName);
  late final _price = TextEditingController(text: _old == null ? '' : formatPesos(_old.monthlyPrice));
  late final _electricityEstimate = TextEditingController(
    text: (_old?.electricityEstimate ?? 0) > 0 ? '${_old!.electricityEstimate}' : '',
  );
  late final _wifiPrice = TextEditingController(text: (_old?.wifiPrice ?? 0) > 0 ? '${_old!.wifiPrice}' : '');

  late RoomType _type = _old?.type ?? RoomType.bedspace;
  late RoomFloor _floor = _old?.floor ?? RoomFloor.ground;
  late int _capacity = _old == null || _old.capacity < 2 ? 2 : _old.capacity;
  late bool _privateCr = _old?.privateCr ?? false;
  late bool _available = _old?.available ?? true;
  late ElectricityCost _electricity = _old?.electricity ?? ElectricityCost.included;
  late WaterCost _water = _old?.water ?? WaterCost.included;
  late WifiCost _wifi = _old?.wifi ?? WifiCost.none;
  late String _moveIn = _old?.moveIn ?? moveInOptions.first;
  late List<String> _included = [...?_old?.included];
  late List<PickedPhoto> _photos = [...?_old?.photos.map(PickedPhoto.uploaded)];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Keep "Students will see" up to date while typing.
    for (final c in [_price, _electricityEstimate, _wifiPrice]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _price, _electricityEstimate, _wifiPrice]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The room as typed so far. Null pieces count as 0.
  Room _room({required List<String> photos}) => Room(
    id: _old?.id ?? '',
    propertyId: widget.property.id,
    landlordId: widget.property.landlordId,
    name: _name.text.trim(),
    type: _type,
    capacity: _type == RoomType.solo ? 1 : _capacity,
    monthlyPrice: parsePesos(_price.text) ?? 0,
    privateCr: _privateCr,
    available: _available,
    included: _included,
    photos: photos,
    floor: _floor,
    electricity: _electricity,
    electricityEstimate: parsePesos(_electricityEstimate.text) ?? 0,
    water: _water,
    wifi: _wifi,
    wifiPrice: parsePesos(_wifiPrice.text) ?? 0,
    moveIn: _moveIn,
  );

  Future<void> _save() async {
    final problem = checkRoomForm(
      name: _name.text,
      photoCount: _photos.length,
      price: parsePesos(_price.text),
      electricityEstimate: _electricity == ElectricityCost.ownMeter ? parsePesos(_electricityEstimate.text) : 1,
      wifiPrice: _wifi == WifiCost.paid ? parsePesos(_wifiPrice.text) : 1,
    );
    if (problem != null) return showError(context, problem);

    setState(() => _saving = true);
    try {
      await RoomService().save(_room(photos: _old?.photos ?? const []), _photos, wasOpen: _old?.available ?? false);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't save. Check your internet and try again.");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final sure = await showConfirmDelete(
      context,
      title: 'Delete ${_old!.name}?',
      message: "Students won't see this room anymore. This can't be undone.",
    );
    if (!sure || !mounted) return;
    setState(() => _saving = true);
    try {
      await RoomService().delete(_old.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) await showError(context, "Couldn't delete. Check your internet and try again.");
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rent = parsePesos(_price.text);
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Row(
              children: [
                CloseCircleButton(onTap: () => Navigator.maybePop(context)),
                Expanded(
                  child: Text(
                    widget.property.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.label.copyWith(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _old == null ? 'Add ${widget.suggestedName}' : 'Edit ${_old.name}',
              style: AppText.largeTitle.copyWith(fontSize: 30, letterSpacing: -0.8),
            ),
            const SizedBox(height: 16),

            const FormSectionLabel('Which floor?', hint: 'Puts it on your Room Map.'),
            SegmentedPills(
              labels: [for (final f in RoomFloor.values) f.label],
              selected: _floor.index,
              onChanged: (i) => setState(() => _floor = RoomFloor.values[i]),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    title: 'Bedspace',
                    subtitle: '2–6 people',
                    selected: _type == RoomType.bedspace,
                    onTap: () => setState(() => _type = RoomType.bedspace),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeCard(
                    title: 'Solo room',
                    subtitle: '1 person',
                    selected: _type == RoomType.solo,
                    onTap: () => setState(() => _type = RoomType.solo),
                  ),
                ),
              ],
            ),
            if (_type == RoomType.bedspace) ...[
              const SizedBox(height: 14),
              const FormSectionLabel('How many people share it?'),
              _ChoiceRow(
                labels: const ['2', '3', '4', '5', '6'],
                selected: _capacity - 2,
                onTap: (i) => setState(() => _capacity = i + 2),
              ),
            ],
            const SizedBox(height: 14),

            RoomCostsCard(
              perPerson: _type == RoomType.bedspace,
              rent: _price,
              electricity: _electricity,
              electricityEstimate: _electricityEstimate,
              water: _water,
              wifi: _wifi,
              wifiPrice: _wifiPrice,
              moveIn: _moveIn,
              onElectricity: (v) => setState(() => _electricity = v),
              onWater: (v) => setState(() => _water = v),
              onWifi: (v) => setState(() => _wifi = v),
              onMoveIn: (v) => setState(() => _moveIn = v),
            ),
            const SizedBox(height: 10),
            StudentsWillSee(amount: rent == null ? null : _room(photos: const []).estimatedMonthly),
            const SizedBox(height: 24),

            const FormSectionLabel('Room photos', hint: 'Bed, CR, what is included. The first photo is the cover.'),
            PhotoPickerGrid(photos: _photos, onChanged: (p) => setState(() => _photos = p)),
            const SizedBox(height: 24),

            LabeledField(label: 'Room name', controller: _name, placeholder: 'Room 1'),
            const SizedBox(height: 24),

            const FormSectionLabel('Comfort room (CR)'),
            _ChoiceRow(
              labels: const ['Shared CR', 'Own CR'],
              selected: _privateCr ? 1 : 0,
              onTap: (i) => setState(() => _privateCr = i == 1),
            ),
            const SizedBox(height: 24),

            const FormSectionLabel("What's included", hint: 'Tap all that come with the room.'),
            ChipPicker(
              options: roomIncludedOptions,
              selected: _included,
              onChanged: (v) => setState(() => _included = v),
              customPlaceholder: 'Add your own, like "Mini fridge"',
            ),
            const SizedBox(height: 24),

            RoundedCard(
              shadow: false,
              radius: 22,
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Open now', style: AppText.label.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Turn off when someone takes the room.', style: AppText.secondary.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: _available,
                    activeTrackColor: AppColors.lagoon,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(label: _old == null ? 'Save room' : 'Save changes', loading: _saving, onPressed: _save),
            if (_old != null) DeleteTextButton(label: 'Delete room', onPressed: _saving ? null : _delete),
          ],
        ),
      ),
    );
  }
}

/// Returns what's wrong with the room form, or null if it's ready to save.
/// [electricityEstimate] and [wifiPrice] are only checked when the landlord picked "Own meter" / "Paid".
String? checkRoomForm({
  required String name,
  required int photoCount,
  required int? price,
  int? electricityEstimate = 1,
  int? wifiPrice = 1,
}) {
  if (name.trim().isEmpty) return 'Please give the room a name, like "Room 1".';
  if (photoCount == 0) return 'Please add at least 1 photo of the room.';
  if (price == null) return 'Please type the monthly rent in pesos.';
  if (price <= 0) return 'The rent must be more than ₱0.';
  if (electricityEstimate == null || electricityEstimate <= 0) {
    return 'Please type about how much electricity costs a month.';
  }
  if (wifiPrice == null || wifiPrice <= 0) return 'Please type the monthly Wi-Fi price.';
  return null;
}

/// "Bedspace / 2–6 people" card; the picked one has a lagoon border.
class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.title, required this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.lagoon : AppColors.card, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.label.copyWith(fontSize: 15)),
              Text(subtitle, style: AppText.secondary.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of chips where exactly one is picked.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.labels, required this.selected, required this.onTap});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          TagChip(label: labels[i], selected: i == selected, onTap: () => onTap(i)),
      ],
    );
  }
}
