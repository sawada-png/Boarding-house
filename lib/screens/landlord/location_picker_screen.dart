import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/pin_map.dart';
import '../../widgets/primary_button.dart';

/// Full-screen map. Tap where the boarding house is, then "Use this location".
/// Returns the chosen point, or nothing if the user goes back.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng? _pin = widget.initial;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: PinMap(pin: _pin, onTap: (p) => setState(() => _pin = p)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleBackButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Text(
                            _pin == null ? 'Tap the map where your boarding house is' : 'Tap again to move the pin',
                            style: AppText.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Use this location',
                    onPressed: _pin == null ? null : () => Navigator.pop(context, _pin),
                  ),
                  const SizedBox(height: 16), // leave room for the map credit
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
