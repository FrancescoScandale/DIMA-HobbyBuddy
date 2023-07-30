import 'package:shared_preferences/shared_preferences.dart';

/// A class to manage the app's shared preferences
class Preferences {
  static late SharedPreferences _prefs;

  /// init function for SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get function for bool
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Set function for bool
  static Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }
}
