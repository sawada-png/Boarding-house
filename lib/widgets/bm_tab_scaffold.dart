import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// One tab in the bottom bar.
class BmTab {
  const BmTab({required this.icon, required this.label, required this.builder});

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// Screen with the floating dark pill tab bar. Used by student mode and landlord mode.
/// Each tab keeps its own page history, and a tab is only built the first time it's opened.
class BmTabScaffold extends StatefulWidget {
  const BmTabScaffold({super.key, required this.tabs});

  final List<BmTab> tabs;

  /// Space screens should leave at the bottom so the bar doesn't cover them.
  static const bottomSpace = 120.0;

  @override
  State<BmTabScaffold> createState() => _BmTabScaffoldState();
}

class _BmTabScaffoldState extends State<BmTabScaffold> {
  int _index = 0;
  final _opened = <int>{0};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < widget.tabs.length; i++)
              _opened.contains(i) ? CupertinoTabView(builder: widget.tabs[i].builder) : const SizedBox(),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 28,
          child: SafeArea(
            top: false,
            child: _FloatingBar(
              tabs: widget.tabs,
              index: _index,
              onTap: (i) => setState(() {
                _index = i;
                _opened.add(i);
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingBar extends StatelessWidget {
  const _FloatingBar({required this.tabs, required this.index, required this.onTap});

  final List<BmTab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Color(0x470F1D20), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              // The open tab gets more room for its label.
              flex: i == index ? 3 : 2,
              child: _TabButton(tab: tabs[i], selected: i == index, onTap: () => onTap(i)),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.tab, required this.selected, required this.onTap});

  final BmTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : const Color(0xFFC9D3D0);
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.card : const Color(0x00FFFFFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon, size: 20, color: color),
              if (selected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
