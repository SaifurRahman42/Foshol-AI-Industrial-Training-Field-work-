import 'dart:convert';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover});

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.eco, size: 36, color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder(context);

    // Gallery images are kept as data:image/...;base64,... strings.
    if (url.startsWith('data:image/')) {
      try {
        final comma = url.indexOf(',');
        if (comma < 0) return _placeholder(context);
        final bytes = base64Decode(url.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stack) => _placeholder(context),
        );
      } catch (_) {
        return _placeholder(context);
      }
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: total != null
                ? progress.cumulativeBytesLoaded / total
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stack) => _placeholder(context),
    );
  }
}
