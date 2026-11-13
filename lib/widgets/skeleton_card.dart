import 'package:flutter/material.dart';

/// Pulsing placeholder shown while the first page is loading.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(width: 110, height: double.infinity, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(140, 16),
                    const SizedBox(height: 8),
                    bar(90, 12),
                    const SizedBox(height: 8),
                    bar(double.infinity, 12),
                    const Spacer(),
                    bar(60, 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
