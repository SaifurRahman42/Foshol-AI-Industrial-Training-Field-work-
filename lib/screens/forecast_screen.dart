import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../widgets/fade_slide.dart';

class ForecastScreen extends StatelessWidget {
  final String districtName;
  final List<DailyForecast> daily;

  const ForecastScreen({
    super.key,
    required this.districtName,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$districtName - 7 days')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daily.length,
            itemBuilder: (context, index) {
              final day = daily[index];
              return FadeSlide(
                index: index,
                child: Card(
                  child: ListTile(
                    leading: Icon(weatherIcon(day.weatherCode), size: 32),
                    title: Text(index == 0 ? 'Today' : formatDate(day.date)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(weatherLabel(day.weatherCode)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (day.rainSum / 30).clamp(0.0, 1.0),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Rain ${day.rainSum.toStringAsFixed(1)} mm',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    trailing: Text(
                      '${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
