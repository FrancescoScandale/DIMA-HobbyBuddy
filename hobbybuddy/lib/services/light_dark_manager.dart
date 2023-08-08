import 'package:hobbybuddy/services/preferences.dart';
import 'package:flutter/material.dart';

// class ThemeManager {
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode =
      Preferences.getBool('isDark') ? ThemeMode.dark : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    Preferences.setBool('isDark', themeMode == ThemeMode.dark);
    notifyListeners();
  }
}
