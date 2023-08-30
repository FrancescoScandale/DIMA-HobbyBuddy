import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/home_page.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      "username": "user",
      "hobbies": ["Skateboard"],
    });
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    await firestore.collection("users").add({
      "username": "user",
      "hobbies": "Skateboard",
    });
    await firestore.collection("hobbies").doc("d11XvjCVnj8hKbXzIlDO").set({
      "hobby": "Volleyball,Skateboard",
    });
  });
  group('home page screen test', () {
    // Mock SharedPreferences initialization

    testWidgets('Hobby container can be tapped', (WidgetTester tester) async {
      await Preferences.init();

      // Create a MaterialApp with a HomePScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the app bar title is displayed

      expect(find.text('Hobby Buddy'), findsOneWidget);
      // Verify that the search input field is displayed
      expect(find.byType(TextField), findsOneWidget);
      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                widget.image.toString().contains('Volleyball.png'),
          ),
          findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('Volleyball'), findsOneWidget);

      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                widget.image.toString().contains('Skateboard.png'),
          ),
          findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Skateboard'), findsOneWidget);
      await tester.tap(find.text('Skateboard'));
    });
  });

  testWidgets('Hobbies can be searched', (WidgetTester tester) async {
    await Preferences.init();

    // Create a MaterialApp with a HomePScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the app bar title is displayed

    expect(find.text('Hobby Buddy'), findsOneWidget);
    // Verify that the search input field is displayed

    final search = find.byType(TextField);
    expect(search, findsOneWidget);
    await tester.enterText(search, 's');
    await tester.tap(find.byIcon(Icons.search_sharp));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.sort_by_alpha_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Skateboard'), findsOneWidget);
    expect(find.text('Volleyball'), findsNothing);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Skateboard'), findsOneWidget);
    expect(find.text('Volleyball'), findsOneWidget);
  });
}
