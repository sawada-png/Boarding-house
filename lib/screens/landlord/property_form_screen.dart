import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:latlong2/latlong.dart';

import '../../models/picked_photo.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/chip_picker.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/delete_text_button.dart';
import '../../widgets/form_section_label.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/photo_picker_grid.dart';
import '../../widgets/pin_map.dart';
import '../../widgets/primary_button.dart';
import '../shared/dialogs.dart';
import 'location_picker_screen.dart';

/// Add a new boarding house, or edit one when [existing] is given.
class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key, required this.landlordId, this.existing});

  final String landlordId;
  final Property? existing;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  late final Property? _old = widget.existing;
  late final _name = TextEditingController(text: _old?.name);
  late final _description = TextEditingController(text: _old?.description);
  late final _area = TextEditingController(text: _old?.area);
  late final _priceMin = TextEditingController(text: _old == null ? '' : '${_old.priceMin}');
  late final _priceMax = TextEditingController(text: _old == null ? '' : '${_old.priceMax}');

  late LatLng? _pin = _old == null ? null : LatLng(_old.latitude, _old.longitude);
  late List<PickedPhoto> _photos = [...?_old?.photos.map(PickedPhoto.uploaded)];
  late List<String> _tags = [...?_old?.tags];
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _area, _description, _priceMin, _priceMax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final point = await Navigator.push<LatLng>(
      context,
      CupertinoPageRoute(builder: (_) => LocationPickerScreen(initial: _pin)),
    );
    if (point != null) setState(() => _pin = point);
  }

  Future<void> _save() async {
    final min = parsePesos(_priceMin.text);
    final max = parsePesos(_priceMax.text);
    final problem = checkPropertyForm(
      name: _name.text,
      hasLocation: _pin != null,
      photoCount: _photos.length,
      priceMin: min,
      priceMax: max,
    );
    if (problem != null) return showError(context, problem);

    setState(() => _saving = true);
    try {
      await PropertyService().save(
        Property(
          id: _old?.id ?? '',
          landlordId: widget.landlordId,
          name: _name.text.trim(),
          area: _area.text.trim(),
          description: _description.text.trim(),
          latitude: _pin!.latitude,
          longitude: _pin!.longitude,
          priceMin: min!,
          priceMax: max!,
          tags: _tags,
          photos: _old?.photos ?? const [],
        ),
        _photos,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        await showError(context, "Couldn't save. Check your internet and try again.");
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final sure = await showConfirmDelete(
      context,
      title: 'Delete ${_old!.name}?',
      message: "This also deletes all its rooms. Students won't see it anymore. This can't be undone.",
    );
    if (!sure || !mounted) return;
    setState(() => _saving = true);
    try {
      await PropertyService().delete(_old);
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
            Text(
              _old == null ? 'Add your boarding house' : 'Edit boarding house',
              style: AppText.largeTitle.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 28),

            FormSectionLabel('Photos', hint: 'Outside, hallway, common areas. The first photo is the cover.'),
            PhotoPickerGrid(photos: _photos, onChanged: (p) => setState(() => _photos = p)),
            const SizedBox(height: 24),

            LabeledField(
              label: 'Name',
              controller: _name,
              placeholder: "Nathan's Boarding House",
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            LabeledField(
              label: 'Area / barangay (optional)',
              controller: _area,
              placeholder: 'Mandaragat',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            FormSectionLabel('Location', hint: 'Students use this to see how far it is from campus.'),
            _LocationBox(pin: _pin, onTap: _pickLocation),
            const SizedBox(height: 24),

            FormSectionLabel('Price range per month', hint: 'Cheapest room to most expensive room.'),
            Row(
              children: [
                Expanded(
                  child: LabeledField(
                    label: 'From',
                    controller: _priceMin,
                    placeholder: '3,000',
                    prefixText: '₱',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    label: 'To',
                    controller: _priceMax,
                    placeholder: '4,500',
                    prefixText: '₱',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            FormSectionLabel('Tags', hint: 'Tap all that fit.'),
            ChipPicker(
              options: propertyTagOptions,
              selected: _tags,
              onChanged: (t) => setState(() => _tags = t),
              customPlaceholder: 'Add your own, like "Curfew 10 PM"',
            ),
            const SizedBox(height: 24),

            LabeledField(
              label: 'Description (optional)',
              controller: _description,
              placeholder: 'Near the jeepney stop, quiet street, 24/7 guard...',
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              label: _old == null ? 'Save boarding house' : 'Save changes',
              loading: _saving,
              onPressed: _save,
            ),
            if (_old != null) DeleteTextButton(label: 'Delete boarding house', onPressed: _saving ? null : _delete),
          ],
        ),
      ),
    );
  }
}

/// Returns what's wrong with the form, or null if it's ready to save.
String? checkPropertyForm({
  required String name,
  required bool hasLocation,
  required int photoCount,
  required int? priceMin,
  required int? priceMax,
}) {
  if (name.trim().isEmpty) return 'Please type the name of your boarding house.';
  if (photoCount == 0) return 'Please add at least 1 photo.';
  if (!hasLocation) return 'Please set the location on the map.';
  if (priceMin == null || priceMax == null) return 'Please type the price range in pesos.';
  if (priceMin <= 0 || priceMax <= 0) return 'Prices must be more than ₱0.';
  if (priceMin > priceMax) return 'The "From" price should be lower than the "To" price.';
  return null;
}

/// Small map preview with the pin, or a button to set it.
class _LocationBox extends StatelessWidget {
  const _LocationBox({required this.pin, required this.onTap});

  final LatLng? pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: pin == null ? 'Set location on map' : 'Change location',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 160,
            child: pin == null
                ? Container(
                    color: AppColors.card,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.map_pin_ellipse, color: AppColors.lagoon, size: 32),
                        const SizedBox(height: 6),
                        Text('Set location on map', style: AppText.label.copyWith(color: AppColors.lagoon)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      // Key makes the preview re-center when the pin moves.
                      PinMap(key: ValueKey(pin), pin: pin, interactive: false),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
                          child: Text('Change', style: AppText.small.copyWith(color: AppColors.lagoon)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
