import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'api_client.dart';

class ProductPage {
  final List<Product> items;
  final int total;

  const ProductPage(this.items, this.total);
}

/// DummyJSON (https://dummyjson.com) - public REST API with pagination,
/// search and simulated create / update / delete.
class ProductService {
  static const String _host = 'dummyjson.com';
  static const String category = 'groceries';
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  Future<ProductPage> fetchProducts({
    required int skip,
    required int limit,
  }) async {
    final uri = Uri.https(_host, '/products/category/$category', {
      'limit': '$limit',
      'skip': '$skip',
    });
    final json = await sendRequest(http.get(uri));

    final items = (json['products'] as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = (json['total'] as num?)?.toInt() ?? items.length;
    return ProductPage(items, total);
  }

  Future<List<Product>> searchProducts(String query) async {
    final uri = Uri.https(_host, '/products/search', {
      'q': query,
      'limit': '100',
    });
    final json = await sendRequest(http.get(uri));

    return (json['products'] as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .where((p) => p.category == category)
        .toList();
  }

  Future<void> addProduct(Product product) async {
    await sendRequest(http.post(
      Uri.https(_host, '/products/add'),
      headers: _jsonHeaders,
      body: jsonEncode(product.toJson()),
    ));
  }

  Future<void> updateProduct(Product product) async {
    await sendRequest(http.put(
      Uri.https(_host, '/products/${product.id}'),
      headers: _jsonHeaders,
      body: jsonEncode(product.toJson()),
    ));
  }

  Future<void> deleteProduct(int id) async {
    await sendRequest(http.delete(Uri.https(_host, '/products/$id')));
  }
}
