import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/fade_slide.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const Map<SortOption, String> _sortLabels = {
    SortOption.none: 'Default',
    SortOption.priceLow: 'Price: low to high',
    SortOption.priceHigh: 'Price: high to low',
    SortOption.rating: 'Top rated',
    SortOption.name: 'A to Z',
  };

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 520,
    mainAxisExtent: 140,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
  );

  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<MarketProvider>().loadMore();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onRefresh() async {
    final message = await context.read<MarketProvider>().refresh();
    if (message != null && mounted) _showMessage(message);
  }

  Future<void> _openAddForm() async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (message != null && mounted) _showMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: const [ThemeToggleButton()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: Column(
        children: [
          _buildSearchBar(market),
          _buildFilters(market),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildList(market),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MarketProvider market) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              market.onSearchChanged(value);
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search crops, produce...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        market.onSearchChanged('');
                      },
                    ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(
            height: 3,
            child: market.isSearching
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(MarketProvider market) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          FilterChip(
            showCheckmark: false,
            avatar: Icon(
              market.favoritesOnly ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: Colors.red,
            ),
            label: const Text('Favorites'),
            selected: market.favoritesOnly,
            onSelected: (_) => market.toggleFavoritesOnly(),
          ),
          const SizedBox(width: 8),
          for (final option in SortOption.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_sortLabels[option]!),
                selected: market.sort == option,
                onSelected: (_) => market.setSort(option),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(MarketProvider market) {
    final items = market.products;
    final isInitialLoading = (market.isLoading && items.isEmpty) ||
        (market.query.isNotEmpty && market.isSearching && items.isEmpty);
    final errorMessage = market.errorMessage;

    final slivers = <Widget>[];

    if (isInitialLoading) {
      slivers.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (context, i) => const SkeletonCard(),
            childCount: 6,
          ),
        ),
      ));
    } else if (errorMessage != null && items.isEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: ErrorView(
          message: errorMessage,
          onRetry: market.query.isEmpty
              ? market.loadInitial
              : () => market.onSearchChanged(market.query),
        ),
      ));
    } else if (items.isEmpty) {
      slivers.add(SliverToBoxAdapter(child: _buildEmpty(market)));
    } else {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${items.length} item${items.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final product = items[i];
              return FadeSlide(
                key: ValueKey(product.id),
                index: i % 10,
                child: ProductCard(
                  product: product,
                  isFavorite: market.isFavorite(product.id),
                  onFavorite: () => market.toggleFavorite(product.id),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ));
                  },
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ));
      slivers.add(SliverToBoxAdapter(child: _buildFooter(market)));
    }

    return CustomScrollView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }

  Widget _buildEmpty(MarketProvider market) {
    final String text;
    if (market.favoritesOnly) {
      text = 'No favorites yet. Tap the heart on an item to save it.';
    } else if (market.query.isNotEmpty) {
      text = 'No items match "${market.query}".';
    } else {
      text = 'No items to show.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFooter(MarketProvider market) {
    const padding = EdgeInsets.fromLTRB(16, 12, 16, 96);

    if (market.query.isNotEmpty) {
      return const SizedBox(height: 96);
    }
    if (market.isLoadingMore) {
      return const Padding(
        padding: padding,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (market.loadMoreError != null) {
      return Padding(
        padding: padding,
        child: Column(
          children: [
            Text(market.loadMoreError!),
            TextButton.icon(
              onPressed: market.loadMore,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (market.hasMore) {
      return Padding(
        padding: padding,
        child: Center(
          child: TextButton.icon(
            onPressed: market.loadMore,
            icon: const Icon(Icons.expand_more),
            label: const Text('Load more'),
          ),
        ),
      );
    }
    return const Padding(
      padding: padding,
      child: Center(child: Text('You have reached the end')),
    );
  }
}
