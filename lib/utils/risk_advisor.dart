import '../models/weather_model.dart';

enum Crop { rice, potato, tomato }

extension CropLabel on Crop {
  String get label {
    switch (this) {
      case Crop.rice:
        return 'Rice';
      case Crop.potato:
        return 'Potato';
      case Crop.tomato:
        return 'Tomato';
    }
  }
}

enum RiskLevel { low, medium, high }

class Advice {
  final String title;
  final String message;
  final RiskLevel level;

  const Advice(this.title, this.message, this.level);
}

/// Simple rule-based advice from weather data.
/// No pesticide or fertilizer doses are given on purpose.
List<Advice> buildAdvice(Crop crop, WeatherData data) {
  final c = data.current;
  final rain3Days =
      data.daily.take(3).fold<double>(0, (sum, d) => sum + d.rainSum);
  final todayRain = data.daily.isNotEmpty ? data.daily.first.rainSum : 0.0;
  final advice = <Advice>[];

  switch (crop) {
    case Crop.rice:
      if (c.humidity >= 85 && c.temperature >= 24 && c.temperature <= 32) {
        advice.add(const Advice(
            'Rice blast risk',
            'High humidity with warm weather favors blast disease. Inspect leaves for spindle-shaped spots.',
            RiskLevel.high));
      } else if (c.humidity >= 75) {
        advice.add(const Advice(
            'Fungal disease watch',
            'Humidity is fairly high. Check your field regularly.',
            RiskLevel.medium));
      }
      if (rain3Days >= 60) {
        advice.add(const Advice(
            'Heavy rain expected',
            'Keep field drainage open to avoid waterlogging.',
            RiskLevel.medium));
      }
      if (c.temperature >= 36) {
        advice.add(const Advice(
            'Heat stress',
            'Very hot weather. Maintain proper water level in the field.',
            RiskLevel.high));
      }
      break;
    case Crop.potato:
      if (c.humidity >= 80 && c.temperature <= 25) {
        advice.add(const Advice(
            'Late blight risk',
            'Cool and humid weather favors late blight. Look for dark water-soaked patches on leaves.',
            RiskLevel.high));
      }
      if (c.temperature >= 32) {
        advice.add(const Advice(
            'Heat warning',
            'High temperature can reduce tuber formation.',
            RiskLevel.medium));
      }
      break;
    case Crop.tomato:
      if (c.humidity >= 80 && (c.rain > 0 || rain3Days >= 10)) {
        advice.add(const Advice(
            'Fungal disease risk',
            'Wet and humid conditions favor leaf spot and blight. Avoid wetting leaves.',
            RiskLevel.high));
      }
      if (c.temperature >= 35) {
        advice.add(const Advice(
            'Flower drop risk',
            'Very hot weather can cause flower drop. Consider shading or light irrigation.',
            RiskLevel.high));
      }
      if (c.temperature <= 12) {
        advice.add(const Advice(
            'Cold stress',
            'Low temperature slows tomato growth. Protect young plants.',
            RiskLevel.medium));
      }
      break;
  }

  if (advice.isEmpty) {
    advice.add(Advice(
        'No major risk for ${crop.label}',
        'Current weather does not show a strong disease or stress risk.',
        RiskLevel.low));
  }

  // Spraying conditions (general, applies to every crop)
  if (c.windSpeed >= 20 || c.rain > 0 || todayRain >= 2) {
    advice.add(const Advice(
        'Avoid spraying today',
        'Wind or rain can wash away or drift spray. Wait for calmer, dry weather.',
        RiskLevel.medium));
  } else {
    advice.add(const Advice(
        'Good spraying conditions',
        'Low wind and no rain. Follow the product label and local expert advice.',
        RiskLevel.low));
  }

  return advice;
}
