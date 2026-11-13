import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/market_provider.dart';
import 'utils/app_colors.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('foshol_market_cache');
  runApp(const FosholAiApp());
}

class FosholAiApp extends StatelessWidget {
  const FosholAiApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: brightness,
      ).copyWith(
        primary: brightness == Brightness.dark ? AppColors.lime : AppColors.green,
        onPrimary: brightness == Brightness.dark ? AppColors.deepGreen : Colors.white,
        secondary: AppColors.lime,
        surface: brightness == Brightness.dark ? AppColors.deepGreen : AppColors.cream,
      ),
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? AppColors.deepGreen : AppColors.cream,
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()..loadInitial()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Foshol-AI',
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: theme.mode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
