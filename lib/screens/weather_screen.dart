import 'package:flutter/material.dart';


import '../models/district.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/risk_advisor.dart';
import '../widgets/advice_card.dart';
import '../widgets/brand_title.dart';
import '../widgets/error_view.dart';
import '../widgets/fade_slide.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/weather_card.dart';
import 'forecast_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();

  District _district = districts.first;
  Crop _crop = Crop.rice;
  late Future<WeatherData> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchWeather(_district);
  }

  void _load() {
    setState(() {
      _future = _service.fetchWeather(_district);
    });
  }

  Future<void> _refresh() async {
    _load();
    try {
      await _future;
    } catch (_) {
      // The error is shown by the FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildDistrictDropdown(),
                const SizedBox(height: 12),
                _buildCropChips(),
                const SizedBox(height: 16),
                FutureBuilder<WeatherData>(
                  future: _future,
                  builder: _buildContent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<District>(
      initialValue: _district,
      decoration: const InputDecoration(
        labelText: 'District',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
      items: districts
          .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        _district = value;
        _load();
      },
    );
  }

  Widget _buildCropChips() {
    const icons = {
      Crop.rice: Icons.grass,
      Crop.potato: Icons.circle,
      Crop.tomato: Icons.local_florist,
    };

    return Wrap(
      spacing: 8,
      children: Crop.values.map((crop) {
        return ChoiceChip(
          avatar: Icon(icons[crop], size: 18),
          label: Text(crop.label),
          selected: _crop == crop,
          onSelected: (_) => setState(() => _crop = crop),
        );
      }).toList(),
    );
  }

  Widget _buildContent(BuildContext context, AsyncSnapshot<WeatherData> snap) {
    Widget content;

    if (snap.connectionState == ConnectionState.waiting) {
      content = const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (snap.hasError) {
      content = ErrorView(
        key: const ValueKey('error'),
        message: snap.error.toString(),
        onRetry: _load,
      );
    } else {
      final data = snap.data;
      if (data == null || data.daily.isEmpty) {
        content = ErrorView(
          key: const ValueKey('empty'),
          message: 'No weather data available.',
          onRetry: _load,
        );
      } else {
        content = _buildData(context, data);
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: content,
    );
  }

  Widget _buildData(BuildContext context, WeatherData data) {
    final adviceList = buildAdvice(_crop, data);

    return Column(
      key: ValueKey('data-${_district.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherCard(districtName: _district.name, weather: data.current),
        const SizedBox(height: 16),
        Text('Advice for ${_crop.label}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < adviceList.length; i++)
          FadeSlide(
            key: ValueKey('${_crop.name}-$i'),
            index: i,
            child: AdviceCard(advice: adviceList[i]),
          ),
        const SizedBox(height: 8),
        Text(
          'This is general guidance based on weather only. Consult a local agriculture officer before using any pesticide or fertilizer.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ForecastScreen(
                districtName: _district.name,
                daily: data.daily,
              ),
            ));
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('View 7-day forecast'),
        ),
      ],
    );
  }
}
