import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dashed_box.dart';
import 'striped_box.dart';

/// One box on the Room Map.
class RoomMapTile {
  const RoomMapTile({
    required this.id,
    required this.label,
    this.open = false,
    this.price,
    this.detail,
    this.shared = false,
  });

  /// Shared space (kitchen, CR): drawn with a dashed outline, not tappable.
  const RoomMapTile.shared({required this.id, required this.detail})
    : label = 'Shared',
      open = false,
      price = null,
      shared = true;

  final String id;

  /// "Room 2"
  final String label;
  final bool open;

  /// "₱4,500", shown on open rooms.
  final String? price;

  /// "solo · own CR"
  final String? detail;
  final bool shared;
}

/// One floor of the house, like "2F" with its rooms.
class RoomMapFloor {
  const RoomMapFloor({required this.label, required this.tiles});

  /// "GF", "2F", "3F"
  final String label;
  final List<RoomMapTile> tiles;
}

/// The house drawn as rows by floor, top floor first. Open rooms are lagoon with a price,
/// taken rooms are gray stripes, and the selected room gets an orange ring.
class RoomMap extends StatelessWidget {
  const RoomMap({
    super.key,
    required this.floors,
    this.selectedId,
    this.onTap,
    this.title = 'Room Map',
    this.hint,
    this.trailing,
  });

  /// Top floor first, ground floor last.
  final List<RoomMapFloor> floors;
  final String? selectedId;
  final ValueChanged<RoomMapTile>? onTap;
  final String title;

  /// Small gray line under the map, like "Tap an open room to see photos".
  final String? hint;

  /// Shown at the top right instead of the Open/Taken legend (for example "+ Add room").
  final Widget? trailing;

  static const _columns = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.section)),
              trailing ?? const _Legend(),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 22, child: CustomPaint(painter: _RoofPainter())),
          const SizedBox(height: 6),
          for (final floor in floors) ..._floorRows(floor),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: AppText.secondary.copyWith(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// A floor with more than 3 rooms wraps onto extra rows; only the first row shows the label.
  List<Widget> _floorRows(RoomMapFloor floor) {
    final rows = <Widget>[];
    final tiles = floor.tiles.isEmpty ? <RoomMapTile?>[null] : floor.tiles;
    for (var start = 0; start < tiles.length; start += _columns) {
      final chunk = tiles.skip(start).take(_columns).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: SizedBox(
            height: 74,
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: start == 0
                      ? Text(floor.label, style: AppText.small.copyWith(fontSize: 11, color: AppColors.textSecondary))
                      : null,
                ),
                for (var i = 0; i < _columns; i++) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: i < chunk.length && chunk[i] != null
                        ? _Tile(
                            tile: chunk[i]!,
                            selected: chunk[i]!.id == selectedId,
                            onTap: onTap == null || chunk[i]!.shared ? null : () => onTap!(chunk[i]!),
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return rows;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile, required this.selected, this.onTap});

  final RoomMapTile tile;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget box;
    if (tile.shared) {
      box = DashedBox(
        child: _content(AppColors.textSecondary, label: 'Shared', small: tile.detail),
      );
    } else if (tile.open) {
      box = DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.lagoon,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? const [
                  BoxShadow(color: AppColors.orange, spreadRadius: 5),
                  BoxShadow(color: AppColors.card, spreadRadius: 3),
                ]
              : null,
        ),
        child: _content(AppColors.card, label: tile.label, price: tile.price, small: tile.detail),
      );
    } else {
      box = StripedBox(child: _content(AppColors.takenText, label: tile.label));
    }

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: tile.shared ? 'Shared: ${tile.detail ?? ''}' : '${tile.label}, ${tile.open ? 'open' : 'taken'}',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: box),
    );
  }

  Widget _content(Color color, {required String label, String? price, String? small}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (price != null)
                Text(
                  price,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                ),
              if (small != null)
                Text(
                  small,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3, color: color),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget item(Widget swatch, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 10, height: 10, child: swatch),
        const SizedBox(width: 4),
        Text(text, style: AppText.secondary.copyWith(fontSize: 12)),
      ],
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(
          DecoratedBox(
            decoration: BoxDecoration(color: AppColors.lagoon, borderRadius: BorderRadius.circular(3)),
          ),
          'Open',
        ),
        const SizedBox(width: 10),
        item(const StripedBox(radius: 3, stripe: 2), 'Taken'),
      ],
    );
  }
}

/// The roof line above the rooms.
class _RoofPainter extends CustomPainter {
  const _RoofPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(4, size.height - 1)
      ..lineTo(size.width / 2, 2)
      ..lineTo(size.width - 4, size.height - 1);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC9D3D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_RoofPainter old) => false;
}
