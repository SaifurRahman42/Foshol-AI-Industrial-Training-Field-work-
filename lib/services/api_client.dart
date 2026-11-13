import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Awaits an HTTP request and converts every failure into an [ApiException]
/// with a message that is safe to show to the user.
Future<Map<String, dynamic>> sendRequest(Future<http.Response> request) async {
  try {
    final response = await request.timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
          'Server error (${response.statusCode}). Please try again later.');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  } on ApiException {
    rethrow;
  } on TimeoutException {
    throw const ApiException('Request timed out. Check your connection.');
  } on http.ClientException {
    throw const ApiException('No internet connection.');
  } on FormatException {
    throw const ApiException('Received invalid data from the server.');
  } catch (_) {
    throw const ApiException(
        'Something went wrong. Check your internet and try again.');
  }
}
