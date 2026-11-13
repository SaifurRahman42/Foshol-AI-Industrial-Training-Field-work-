import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class WeatherCard extends StatelessWidget {
  final String districtName;
  final CurrentWeather weather;

  const WeatherCard({
    super.key,
    required this.districtName,
    required this.weather,
  });

  List<Color> _gradient(int code) {
    if (code == 0) return const [Color(0xFFF57C00), Color(0xFFFFB300)];
    if (code <= 3) return const [Color(0xFF1E88E5), Color(0xFF90CAF9)];
    if (code == 45 || code == 48) {
      return const [Color(0xFF78909C), Color(0xFFB0BEC5)];
    }
    if (code >= 95) return const [Color(0xFF37474F), Color(0xFF6A1B9A)];
    if (code >= 51) return const [Color(0xFF1565C0), Color(0xFF546E7A)];
    return const [Color(0xFF546E7A), Color(0xFF90A4AE)];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient(weather.weatherCode),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text(districtName,
                  style: textTheme.titleLarge?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Icon(weatherIcon(weather.weatherCode),
                    size: 64, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text('${weather.temperature.toStringAsFixed(1)}°C',
                  style: textTheme.displaySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(weatherLabel(weather.weatherCode),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
              _Stat(Icons.umbrella, '${weather.rain} mm', 'Rain'),
              _Stat(Icons.air, '${weather.windSpeed} km/h', 'Wind'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
