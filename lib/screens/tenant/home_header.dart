import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/property.dart' show formatPesos;
import '../../models/school.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'home_logic.dart';

/// Pinned top of Home: logo + bell, the dark live board, and search.
/// [collapsed] shrinks it to a slim "PSU · 23 open" bar while the list scrolls.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.school,
    required this.stats,
    required this.collapsed,
    required this.search,
    required this.onSchool,
    required this.onBell,
    required this.onFilters,
    required this.onExpand,
  });

  final School? school;

  /// Null while loading.
  final LiveStats? stats;
  final bool collapsed;
  final TextEditingController search;

  /// Tapping the picked school again clears it (null = whole city).
  final ValueChanged<School?> onSchool;
  final VoidCallback onBell;
  final VoidCallback onFilters;

  /// Slim bar tapped: scroll back to the top.
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: collapsed ? _slim() : _full(),
        ),
      ),
    );
  }

  Widget _slim() {
    final open = stats?.open;
    return Semantics(
      button: true,
      label: 'Show the full header',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onExpand,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              const _LiveDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${school?.code ?? 'Puerto Princesa'}${open == null ? '' : ' · $open open'}',
                  style: AppText.section,
                ),
              ),
              const Icon(CupertinoIcons.search, size: 20, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _full() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'board',
                    style: AppText.section.copyWith(fontSize: 22, letterSpacing: -0.5),
                    children: const [
                      TextSpan(
                        text: 'mate',
                        style: TextStyle(color: AppColors.lagoon),
                      ),
                    ],
                  ),
                ),
              ),
              _CircleIcon(icon: CupertinoIcons.bell, label: 'Notifications', onTap: onBell),
            ],
          ),
          const SizedBox(height: 14),
          _LiveBoard(school: school, stats: stats, onSchool: onSchool),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  controller: search,
                  placeholder: 'Search houses or areas',
                  backgroundColor: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  style: AppText.body.copyWith(fontSize: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  prefixInsets: const EdgeInsetsDirectional.only(start: 14),
                  itemColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              _CircleIcon(icon: CupertinoIcons.slider_horizontal_3, label: 'Filters', onTap: onFilters, square: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// The dark card: school pills, "23 rooms open", the room tile strip, today's changes, cheapest price.
class _LiveBoard extends StatelessWidget {
  const _LiveBoard({required this.school, required this.stats, required this.onSchool});

  final School? school;
  final LiveStats? stats;
  final ValueChanged<School?> onSchool;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final muted = GoogleFonts.inter(fontSize: 12, color: AppColors.onInkMuted);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x2E0F1D20), blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Scrolls sideways on narrow phones instead of overflowing.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final sc in schools) ...[
                        _SchoolPill(
                          label: sc.code,
                          selected: sc.id == school?.id,
                          onTap: () => onSchool(sc.id == school?.id ? null : sc),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _LiveDot(),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onInkGood),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            school == null ? 'In Puerto Princesa right now' : 'Near ${school!.code} right now',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onInkMuted),
          ),
          const SizedBox(height: 2),
          // Counts up quickly to the new number when the school changes.
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: s?.open ?? 0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => Text.rich(
              TextSpan(
                style: AppText.largeTitle.copyWith(color: AppColors.card),
                children: [
                  TextSpan(
                    text: s == null ? '–' : '$value',
                    style: const TextStyle(color: AppColors.onInkGood),
                  ),
                  TextSpan(text: s?.open == 1 ? ' room open' : ' rooms open'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _TileStrip(key: ValueKey(school?.id), tiles: s?.tiles ?? const []),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: muted,
                    children: [
                      TextSpan(
                        text: '+${s?.openedToday ?? 0}',
                        style: const TextStyle(color: AppColors.onInkGood, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' since yesterday'),
                    ],
                  ),
                ),
              ),
              if (s?.cheapest != null)
                Text.rich(
                  TextSpan(
                    style: muted,
                    children: [
                      const TextSpan(text: 'cheapest '),
                      TextSpan(
                        text: '₱${formatPesos(s!.cheapest!)}',
                        style: const TextStyle(color: AppColors.card, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 20 small slots, one per room: green = open, dark = taken, empty = no room.
class _TileStrip extends StatelessWidget {
  const _TileStrip({super.key, required this.tiles});

  final List<bool> tiles;

  @override
  Widget build(BuildContext context) {
    final open = tiles.where((t) => t).length;
    return Semantics(
      label: '$open of ${tiles.length} rooms open',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < LiveStats.maxTiles; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: i >= tiles.length
                      ? AppColors.inkRaised
                      : tiles[i]
                      ? AppColors.liveGreen
                      : AppColors.inkLine,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SchoolPill extends StatelessWidget {
  const _SchoolPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.card : AppColors.inkRaised,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.ink : AppColors.onInkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Green dot with a soft ring that pulses, so "Live" feels live. Still when the phone asks for less motion.
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.liveGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.liveGreen.withValues(alpha: 0.35 * (1 - _pulse.value)),
              spreadRadius: 2 + 5 * _pulse.value,
            ),
          ],
        ),
      ),
    );
  }
}

/// White 44–48px button with an icon (bell, filters).
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.label, required this.onTap, this.square = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Rounded square (filters) instead of a circle (bell).
  final bool square;

  @override
  Widget build(BuildContext context) {
    final size = square ? 48.0 : 44.0;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(square ? 16 : 22)),
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}
