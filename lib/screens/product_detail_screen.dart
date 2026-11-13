import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/market_provider.dart';
import '../services/api_client.dart';
import '../widgets/favorite_button.dart';
import '../widgets/product_image.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Future<void> _edit(BuildContext context, Product p) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _delete(BuildContext context, Product p) async {
    final market = context.read<MarketProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('"${p.title}" will be removed from the list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await market.deleteProduct(p);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('"${p.title}" deleted')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final p = market.byId(product.id);

    if (p == null) {
      return const Scaffold(body: Center(child: Text('This item was removed.')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            actions: [
              FavoriteButton(
                isFavorite: market.isFavorite(p.id),
                onPressed: () => market.toggleFavorite(p.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _Gallery(product: p)),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(p.priceWithUnit,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold)),
                          if (p.discountPercentage >= 1) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                  '${p.discountPercentage.toStringAsFixed(0)}% off'),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                          const Spacer(),
                          _Stars(rating: p.rating),
                          const SizedBox(width: 4),
                          Text(p.rating.toStringAsFixed(1)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.category, size: 16),
                            label: Text(p.category),
                          ),
                          for (final tag in p.tags) Chip(label: Text(tag)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(p.description),
                      const SizedBox(height: 16),
                      _InfoCard(product: p),
                      if (p.reviews.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Reviews (${p.reviews.length})',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        for (final r in p.reviews)
                          Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(child: Text(r.reviewerName)),
                                  _Stars(rating: r.rating.toDouble(), size: 14),
                                ],
                              ),
                              subtitle: Text(r.comment),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _edit(context, p),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: () => _delete(context, p),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  final Product product;

  const _Gallery({required this.product});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.gallery;

    if (images.isEmpty) {
      return Hero(
        tag: 'product-${widget.product.id}',
        child: const ProductImage(url: ''),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) {
            final image = ProductImage(url: images[i], fit: BoxFit.contain);
            if (i == 0) {
              return Hero(
                tag: 'product-${widget.product.id}',
                child: image,
              );
            }
            return image;
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final double size;

  const _Stars({required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star : Icons.star_border,
          size: size,
          color: Colors.amber,
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Product product;

  const _InfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (product.brand != null && product.brand!.isNotEmpty)
        MapEntry('Brand', product.brand!),
      MapEntry('Stock', '${product.stock} available'),
      if (product.availabilityStatus != null)
        MapEntry('Status', product.availabilityStatus!),
      if (product.shippingInformation != null)
        MapEntry('Shipping', product.shippingInformation!),
      if (product.returnPolicy != null)
        MapEntry('Returns', product.returnPolicy!),
      if (product.warrantyInformation != null)
        MapEntry('Warranty', product.warrantyInformation!),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(row.key,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
