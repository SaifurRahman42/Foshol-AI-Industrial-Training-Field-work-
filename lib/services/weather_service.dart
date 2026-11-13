import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/district.dart';
import '../models/weather_model.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(District district) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': district.latitude.toString(),
      'longitude': district.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum',
      'forecast_days': '7',
      'timezone': 'auto',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw WeatherException(
            'Server error (${response.statusCode}). Please try again later.');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw WeatherException('Request timed out. Check your connection.');
    } on http.ClientException {
      throw WeatherException('No internet connection.');
    } on FormatException {
      throw WeatherException('Received invalid data from the server.');
    } catch (_) {
      throw WeatherException(
          'Something went wrong. Check your internet and try again.');
    }
  }
}
