import 'package:flutter/material.dart';

import '../models/product.dart';
import 'favorite_button.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      product.category,
      if (product.brand != null && product.brand!.isNotEmpty) product.brand!,
    ].join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: double.infinity,
              child: Hero(
                tag: 'product-${product.id}',
                child: ProductImage(url: product.thumbnail),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (product.isLocal)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.edit_note, size: 18),
                          ),
                        FavoriteButton(
                          isFavorite: isFavorite,
                          onPressed: onFavorite,
                          size: 22,
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          product.priceWithUnit,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (product.discountPercentage >= 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade900),
                            ),
                          ),
                        ],
                        const Spacer(),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(product.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
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
