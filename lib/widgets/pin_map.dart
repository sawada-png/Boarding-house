import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';

/// Rough center of PSU Tiniguiban, where the map starts when no pin is set.
const defaultMapCenter = LatLng(9.7769, 118.7357);

/// OpenStreetMap map with an optional teal pin. Tap the map to move the pin (if [onTap] is set).
class PinMap extends StatelessWidget {
  const PinMap({super.key, this.pin, this.onTap, this.interactive = true});

  final LatLng? pin;
  final ValueChanged<LatLng>? onTap;

  /// False for a small preview that can't be dragged.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: pin ?? defaultMapCenter,
        initialZoom: pin == null ? 14 : 16,
        onTap: onTap == null ? null : (_, point) => onTap!(point),
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boardmate.boardmate',
        ),
        if (pin != null)
          MarkerLayer(
            markers: [
              Marker(
                point: pin!,
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: const Icon(CupertinoIcons.location_solid, size: 44, color: AppColors.lagoon),
              ),
            ],
          ),
        // OpenStreetMap requires this credit on the map.
        const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
      ],
    );
  }
}
