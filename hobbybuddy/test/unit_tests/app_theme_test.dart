import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCallbackFunction extends Mock {
  call();
}

void main() {
  group('ThemeManager', () {
    late ThemeManager themeManager;
    final notifyListenerCallback = MockCallbackFunction();

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      themeManager = ThemeManager()..addListener(notifyListenerCallback);
    });

    test('get method should return the correct value', () async {
      ThemeMode matcherTheme =
          Preferences.getBool('isDark') ? ThemeMode.dark : ThemeMode.light;
      expect(themeManager.themeMode, matcherTheme);
    });

    test(
        'toogleClock method should set the correct value and notify the listeners',
        () {
      themeManager.toggleTheme(true);
      expect(Preferences.getBool('isDark'), true);
      themeManager.toggleTheme(false);
      expect(Preferences.getBool('isDark'), false);
      // verify notifyListener called twice
      verify(notifyListenerCallback()).called(2);
    });
  });
}
