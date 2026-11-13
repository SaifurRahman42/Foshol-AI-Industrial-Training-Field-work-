import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          size: size,
          color: isFavorite ? Colors.red : null,
        ),
      ),
    );
  }
}
