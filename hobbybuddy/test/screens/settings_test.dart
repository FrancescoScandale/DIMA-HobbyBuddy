import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/settings.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';

import '../mock/mock_app_theme.dart';

final firestore = FakeFirebaseFirestore();

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);

    SharedPreferences.setMockInitialValues({
      'username': 'marta',
      'email': 'marta@gmail.com',
      'isDark': false,
    });
    await firestore.collection("users").add({
      'username': 'marta',
      'email': 'marta@gmail.com',
    });
  });
  group('Settings screen test', () {
    testWidgets('SettingsScreen renders correctly', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
          ],
          child: MaterialApp(
            home: Settings(
              username: 'marta',
              profilePicture: Image.asset('assets/logo.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check if username text is present
      expect(find.text('marta'), findsOneWidget);

      // Check if email text is present
      expect(find.text('marta@gmail.com'), findsOneWidget);

      // Check if image is present
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == 'assets/logo.png',
        ),
        findsOneWidget,
      );

      //light/dark mode
      expect(
        find.byWidgetPredicate((widget) => widget is SwitchListTile),
        findsOneWidget,
      );
      expect(find.text("Dark mode"), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is ListTile),
        findsAtLeastNWidgets(2),
      );
      expect(find.text("Edit profile"), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text("Change password"), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);

      expect(find.byIcon(Icons.navigate_next), findsNWidgets(2));
      // Check if sign out button is present
      expect(find.text('Sign Out'), findsOneWidget);

      // Tap the sign out button and wait for animation to complete
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();
    });

    testWidgets('SettingsScreen renders correctly', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
          ],
          child: MaterialApp(
            home: Settings(
              username: 'marta',
              profilePicture: Image.asset('assets/logo.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) => widget is SwitchListTile),
        findsOneWidget,
      );
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('Dark/light mode switch can be tapped', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
          ],
          child: MaterialApp(
            home: Settings(
              username: 'marta',
              profilePicture: Image.asset('assets/logo.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      //light/dark mode
      expect(
        find.byWidgetPredicate((widget) => widget is SwitchListTile),
        findsOneWidget,
      );
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
    });

    testWidgets('Tap on edit profile', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
          ],
          child: MaterialApp(
            home: Settings(
              username: 'marta',
              profilePicture: Image.asset('assets/logo.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text("Edit profile"));
    });

    testWidgets('Tap on change password', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeManager>(
              create: (context) => MockThemeManger(),
            ),
          ],
          child: MaterialApp(
            home: Settings(
              username: 'marta',
              profilePicture: Image.asset('assets/logo.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text("Change password"));
    });
  });
}
