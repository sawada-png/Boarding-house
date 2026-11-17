import 'package:cupertino_ui/cupertino_ui.dart';

import '../../models/picked_photo.dart';
import '../../models/property.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/delete_text_button.dart';
import '../../widgets/form_section_label.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/photo_picker_grid.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rounded_card.dart';
import '../../widgets/tag_chip.dart';
import '../shared/dialogs.dart';

/// Add a room to a boarding house, or edit one when [existing] is given.
class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({
    super.key,
    required this.property,
    this.existing,
    this.suggestedName = 'Room 1',
  });

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
  late final _price = TextEditingController(text: _old == null ? '' : '${_old.monthlyPrice}');

  late RoomType _type = _old?.type ?? RoomType.bedspace;
  late int _capacity = _old == null || _old.capacity < 2 ? 2 : _old.capacity;
  late bool _privateCr = _old?.privateCr ?? false;
  late bool _available = _old?.available ?? true;
  late List<String> _included = [...?_old?.included];
  late List<PickedPhoto> _photos = [...?_old?.photos.map(PickedPhoto.uploaded)];
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = parsePesos(_price.text);
    final problem = checkRoomForm(name: _name.text, photoCount: _photos.length, price: price);
    if (problem != null) return showError(context, problem);

    setState(() => _saving = true);
    try {
      await RoomService().save(
        Room(
          id: _old?.id ?? '',
          propertyId: widget.property.id,
          landlordId: widget.property.landlordId,
          name: _name.text.trim(),
          type: _type,
          capacity: _type == RoomType.solo ? 1 : _capacity,
          monthlyPrice: price!,
          privateCr: _privateCr,
          available: _available,
          included: _included,
          photos: _old?.photos ?? const [],
        ),
        _photos,
      );
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
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const Align(alignment: Alignment.centerLeft, child: CircleBackButton()),
            const SizedBox(height: 20),
            Text(_old == null ? 'Add a room' : 'Edit room', style: AppText.largeTitle.copyWith(fontSize: 30)),
            const SizedBox(height: 4),
            Text(widget.property.name, style: AppText.secondary),
            const SizedBox(height: 28),

            const FormSectionLabel('Room photos', hint: 'Bed, CR, what is included. The first photo is the cover.'),
            PhotoPickerGrid(photos: _photos, onChanged: (p) => setState(() => _photos = p)),
            const SizedBox(height: 24),

            LabeledField(label: 'Room name', controller: _name, placeholder: 'Room 1'),
            const SizedBox(height: 24),

            const FormSectionLabel('Type of room'),
            _ChoiceRow(
              labels: const ['Bedspace', 'Solo room'],
              selected: _type == RoomType.bedspace ? 0 : 1,
              onTap: (i) => setState(() => _type = i == 0 ? RoomType.bedspace : RoomType.solo),
            ),
            if (_type == RoomType.bedspace) ...[
              const SizedBox(height: 16),
              const FormSectionLabel('How many people share it?'),
              _ChoiceRow(
                labels: const ['2', '3', '4', '5', '6'],
                selected: _capacity - 2,
                onTap: (i) => setState(() => _capacity = i + 2),
              ),
            ],
            const SizedBox(height: 24),

            LabeledField(
              label: _type == RoomType.bedspace ? 'Price per person, per month' : 'Price per month',
              controller: _price,
              placeholder: '3,500',
              prefixText: '₱',
              keyboardType: TextInputType.number,
            ),
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
              radius: 16,
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available now', style: AppText.label.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Turn off when someone takes the room.', style: AppText.secondary.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: _available,
                    activeTrackColor: AppColors.teal,
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
String? checkRoomForm({required String name, required int photoCount, required int? price}) {
  if (name.trim().isEmpty) return 'Please give the room a name, like "Room 1".';
  if (photoCount == 0) return 'Please add at least 1 photo of the room.';
  if (price == null) return 'Please type the monthly price in pesos.';
  if (price <= 0) return 'The price must be more than ₱0.';
  return null;
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
