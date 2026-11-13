import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void toggle(bool isCurrentlyDark) {
    _mode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
