import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';

/// A class to manage the app's shared preferences
class Preferences {
  static late SharedPreferences _prefs;

  /// init function for SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void deleteData(String data) {
    _prefs.remove(data);
  }

  /// Set function for bool
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get function for bool
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static Future<bool> setUsername(String username) async {
    return await _prefs.setString('username', username);
  }

  static String? getUsername() {
    return _prefs.getString('username');
  }

  static Future<bool> setHobbies(String username) async {
    List<String> hobbies = await FirebaseCrud.getUserData(username, 'hobbies');
    return await _prefs.setStringList('hobbies', hobbies);
  }

  static List<String>? getHobbies() {
    return _prefs.getStringList('hobbies');
  }

  static Future<bool> setMentors(String username) async {
    List<String> mentors = await FirebaseCrud.getUserData(username, 'mentors');
    return await _prefs.setStringList('mentors', mentors);
  }

  static List<String>? getMentors() {
    print('heloo');
    return _prefs.getStringList('mentors');
  }

  static Future<bool> setEmail(String username) async {
    String email = await FirebaseCrud.getEmail(username);
    return await _prefs.setString('email', email);
  }

  static String? getEmail() {
    return _prefs.getString('email');
  }
}
