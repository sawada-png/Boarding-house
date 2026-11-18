import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../theme/app_colors.dart';

/// Round save button: outline heart = not saved, filled = saved. Pops and buzzes lightly on tap.
class HeartButton extends StatefulWidget {
  const HeartButton({super.key, required this.saved, required this.onTap, this.size = 44});

  final bool saved;
  final VoidCallback onTap;

  /// 44 in the house header, 36 on listing cards.
  final double size;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
  ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.lightImpact();
    _pop.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      toggled: widget.saved,
      label: widget.saved ? 'Saved. Tap to remove' : 'Save',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _tap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
          child: ScaleTransition(
            scale: _scale,
            child: Icon(
              widget.saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              size: widget.size * 0.45,
              color: widget.saved ? AppColors.orange : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
