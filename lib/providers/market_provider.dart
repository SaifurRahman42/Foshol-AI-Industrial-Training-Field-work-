import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_client.dart';
import '../services/product_service.dart';
import '../services/product_cache_service.dart';

enum SortOption { none, priceLow, priceHigh, rating, name }

class MarketProvider extends ChangeNotifier {
  MarketProvider([ProductService? service])
      : _service = service ?? ProductService();

  static const int pageSize = 10;

  final ProductService _service;
  final ProductCacheService _cache = ProductCacheService();

  // Data from the API (paginated), search results, and in-app changes.
  final List<Product> _items = [];
  List<Product> _searchResults = [];
  final List<Product> _local = [];
  final Set<int> _favorites = {};
  final Set<int> _deleted = {};
  final Map<int, Product> _edits = {};

  int _skip = 0;
  int _total = 0;
  int _nextLocalId = 100000;
  int _searchToken = 0;
  Timer? _debounce;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isSearching = false;
  String? error;
  String? loadMoreError;
  String? searchError;

  String query = '';
  SortOption sort = SortOption.none;
  bool favoritesOnly = false;

  bool get hasMore => query.isEmpty && _skip < _total;

  String? get errorMessage => query.isEmpty ? error : searchError;

  /// Items shown on screen: filtered, edited and sorted.
  List<Product> get products {
    final q = query.toLowerCase();
    final base = query.isEmpty ? _items : _searchResults;

    var list = <Product>[
      ..._local.where((p) => q.isEmpty || p.title.toLowerCase().contains(q)),
      ...base
          .where((p) => !_deleted.contains(p.id))
          .map((p) => _edits[p.id] ?? p),
    ];

    if (favoritesOnly) {
      list = list.where((p) => _favorites.contains(p.id)).toList();
    }

    switch (sort) {
      case SortOption.none:
        break;
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  Product? byId(int id) {
    for (final p in _local) {
      if (p.id == id) return p;
    }
    if (_deleted.contains(id)) return null;
    if (_edits.containsKey(id)) return _edits[id];
    for (final p in [..._items, ..._searchResults]) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool isFavorite(int id) => _favorites.contains(id);


  // ---------- Persistent local cache ----------

  void _restoreCache() {
    try {
      final snapshot = _cache.readSnapshot();
      if (snapshot == null) return;

      List<Product> decodeProducts(String key) {
        final raw = snapshot[key] as List? ?? [];
        return raw
            .map((item) => Product.fromCacheJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }

      _items
        ..clear()
        ..addAll(decodeProducts('items'));
      _local
        ..clear()
        ..addAll(decodeProducts('local'));
      _edits
        ..clear()
        ..addEntries(decodeProducts('edits').map((p) => MapEntry(p.id, p)));
      _deleted
        ..clear()
        ..addAll((snapshot['deleted'] as List? ?? [])
            .map((e) => (e as num).toInt()));
      _favorites
        ..clear()
        ..addAll((snapshot['favorites'] as List? ?? [])
            .map((e) => (e as num).toInt()));

      _skip = (snapshot['skip'] as num?)?.toInt() ?? _items.length;
      _total = (snapshot['total'] as num?)?.toInt() ?? _items.length;
      _nextLocalId =
          (snapshot['nextLocalId'] as num?)?.toInt() ?? _nextLocalId;
    } catch (_) {
      // A corrupted/old cache should never prevent the app from opening.
      _items.clear();
      _local.clear();
      _edits.clear();
      _deleted.clear();
      _favorites.clear();
    }
  }

  Future<void> _saveCache() async {
    await _cache.writeSnapshot({
      'items': _items.map((p) => p.toCacheJson()).toList(),
      'local': _local.map((p) => p.toCacheJson()).toList(),
      'edits': _edits.values.map((p) => p.toCacheJson()).toList(),
      'deleted': _deleted.toList(),
      'favorites': _favorites.toList(),
      'skip': _skip,
      'total': _total,
      'nextLocalId': _nextLocalId,
    });
  }

  // ---------- Loading ----------

  Future<void> loadInitial() async {
    // Render saved data immediately, before attempting a network request.
    _restoreCache();
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final cachedItems = List<Product>.from(_items);
      final page = await _service.fetchProducts(skip: 0, limit: pageSize);

      // Refresh the first page but retain previously cached later pages.
      _items
        ..clear()
        ..addAll(page.items);
      for (final cached in cachedItems) {
        if (!_items.any((item) => item.id == cached.id)) {
          _items.add(cached);
        }
      }
      _total = page.total;
      _skip = _items.length;
      await _saveCache();
    } on ApiException catch (e) {
      // Keep cached data visible when the network is unavailable.
      if (_items.isEmpty && _local.isEmpty) error = e.message;
    }

    isLoading = false;
    notifyListeners();
  }

  /// Pull to refresh. Returns an error message if refreshing failed.
  Future<String?> refresh() async {
    if (query.isNotEmpty) {
      await _runSearch(query);
      return searchError;
    }

    try {
      final page = await _service.fetchProducts(skip: 0, limit: pageSize);
      _items
        ..clear()
        ..addAll(page.items);
      _total = page.total;
      _skip = page.items.length;
      error = null;
      loadMoreError = null;
      await _saveCache();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      if (_items.isEmpty) {
        error = e.message;
        notifyListeners();
      }
      return e.message;
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final page = await _service.fetchProducts(skip: _skip, limit: pageSize);
      for (final p in page.items) {
        if (!_items.any((e) => e.id == p.id)) _items.add(p);
      }
      _skip += page.items.length;
      _total = page.total;
      if (page.items.isEmpty) _total = _skip; // stop asking for more
      await _saveCache();
    } on ApiException catch (e) {
      loadMoreError = e.message;
    }

    isLoadingMore = false;
    notifyListeners();
  }

  // ---------- Search (debounced), sort, filter ----------

  void onSearchChanged(String text) {
    query = text.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      _searchToken++;
      _searchResults = [];
      searchError = null;
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();
    final current = query;
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(current));
  }

  Future<void> _runSearch(String q) async {
    final token = ++_searchToken;
    try {
      final results = await _service.searchProducts(q);
      if (token != _searchToken) return;
      _searchResults = results;
      searchError = null;
    } on ApiException catch (e) {
      if (token != _searchToken) return;
      _searchResults = [];
      searchError = e.message;
    }
    isSearching = false;
    notifyListeners();
  }

  void setSort(SortOption option) {
    sort = option;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    favoritesOnly = !favoritesOnly;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (!_favorites.remove(id)) _favorites.add(id);
    _saveCache();
    notifyListeners();
  }

  // ---------- CRUD ----------
  // The API call is made for real. DummyJSON does not store the change, so the
  // result is also applied to the in-memory lists for the current session.

  Future<void> addProduct(Product draft) async {
    await _service.addProduct(draft);
    final product = draft.copyWith(id: _nextLocalId++, isLocal: true);
    _local.insert(0, product);
    await _saveCache();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product.isLocal) {
      final i = _local.indexWhere((p) => p.id == product.id);
      if (i != -1) _local[i] = product;
    } else {
      await _service.updateProduct(product);
      _edits[product.id] = product;
    }
    await _saveCache();
    notifyListeners();
  }

  Future<void> deleteProduct(Product product) async {
    if (product.isLocal) {
      _local.removeWhere((p) => p.id == product.id);
    } else {
      await _service.deleteProduct(product.id);
      _deleted.add(product.id);
    }
    _favorites.remove(product.id);
    await _saveCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
