import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/home_page.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('home page screen test', () {
    // Mock SharedPreferences initialization
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'hobbies': ['chess'],
      });
    });
    testWidgets('Hobby container can be tapped', (WidgetTester tester) async {
      await Preferences.init();

      // Create a MaterialApp with a HomePScreen
      await tester.pumpWidget(
        MaterialApp(
          home: HomePScreen(),
        ),
      );

      await tester.pumpAndSettle();
      // Verify that the app bar title is displayed
      expect(find.text('Hobby Buddy'), findsOneWidget);
      // Verify that the search input field is displayed
      expect(find.byType(TextField), findsOneWidget);

      // Use find.byWidgetPredicate to find ContainerShadow
      final containerFinder =
          find.byWidgetPredicate((widget) => widget is Container);
      expect(containerFinder, findsOneWidget);

      await tester.tap(containerFinder);
      await tester.pumpAndSettle();
    });
  });
}



    /*testWidgets('HomePScreen should render without hobbies',
        (WidgetTester tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MaterialApp(
          home: HomePScreen(),
        ),
      );

      // Verify that the app bar title is displayed
      expect(find.text('Hobby Buddy'), findsOneWidget);

      // Verify that the search input field is displayed
      expect(find.byType(TextField), findsOneWidget);

      // Verify that no ContainerShadow widget is found
      expect(find.byType(ContainerShadow), findsNothing);
    });*/