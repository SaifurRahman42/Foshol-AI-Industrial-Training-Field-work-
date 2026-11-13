import 'package:flutter/material.dart';

/// Fades a child in while sliding it up. Higher [index] = slightly slower.
class FadeSlide extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeSlide({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final ms = 300 + index.clamp(0, 8) * 90;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
