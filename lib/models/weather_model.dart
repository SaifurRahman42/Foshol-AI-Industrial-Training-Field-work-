double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

class CurrentWeather {
  final double temperature; // °C
  final int humidity; // %
  final double rain; // mm
  final double windSpeed; // km/h
  final int weatherCode;

  const CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.rain,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: _toDouble(json['temperature_2m']),
      humidity: _toInt(json['relative_humidity_2m']),
      rain: _toDouble(json['precipitation']),
      windSpeed: _toDouble(json['wind_speed_10m']),
      weatherCode: _toInt(json['weather_code']),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainSum;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainSum,
    required this.weatherCode,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final d = json['daily'] as Map<String, dynamic>;
    final times = d['time'] as List<dynamic>;
    final maxT = d['temperature_2m_max'] as List<dynamic>;
    final minT = d['temperature_2m_min'] as List<dynamic>;
    final rain = d['precipitation_sum'] as List<dynamic>;
    final codes = d['weather_code'] as List<dynamic>;

    final daily = List<DailyForecast>.generate(times.length, (i) {
      return DailyForecast(
        date: DateTime.parse(times[i] as String),
        maxTemp: _toDouble(maxT[i]),
        minTemp: _toDouble(minT[i]),
        rainSum: _toDouble(rain[i]),
        weatherCode: _toInt(codes[i]),
      );
    });

    return WeatherData(
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: daily,
    );
  }
}
