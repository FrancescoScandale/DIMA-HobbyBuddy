import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/login.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';

final firestore = FakeFirebaseFirestore();
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: MockFirebaseStorage());

    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({});
    await firestore.collection("users").add({
      'username': 'marta',
      'password': '12345678',
      'email': 'martar@gmail.com',
      'friends': '',
      'hobbies': '',
      'location': '',
      'mentors': '',
      'receivedReq': '',
      'sentReq': '',
      'name': 'marta',
      'surname': 'radaelli',
    });
  });
  testWidgets('LogInScreen renders correctly with button', (tester) async {
    await Preferences.init();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );
    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              widget.image.toString().contains('logo.png'),
        ),
        findsOneWidget);
    expect(find.text('Welcome to Hobby Buddy!'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    final userField = find.byKey(const Key("u_field"));
    expect(userField, findsOneWidget);

    final passwordField = find.byKey(const Key("p_field"));
    expect(passwordField, findsOneWidget);
    // Tap the login button
    // ignore: unused_element
    await tester.tap(find.byKey(const Key("go_login")));
    await tester.pump();
    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('LogInScreen logs existing user', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );

    final userField = find.byKey(const Key("u_field"));
    expect(userField, findsOneWidget);
    expect(find.byIcon(Icons.face), findsOneWidget);

    final passwordField = find.byKey(const Key("p_field"));
    expect(passwordField, findsOneWidget);
    expect(find.byIcon(Icons.lock_open), findsOneWidget);

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    final button = find.byKey(const Key("go_login"));
    expect(button, findsOneWidget);

    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.byKey(const Key("go_sign_up")), findsOneWidget);
    expect(find.text("Sign up here"), findsOneWidget);

    // Fill in the username and password fields
    await tester.enterText(userField, 'marta');
    await tester.enterText(passwordField, '12345678');

    // ignore: unused_element

    await tester.tap(find.text("Submit"));
    await tester.pumpAndSettle();
  });

  testWidgets('LogInScreen rejects non existing user', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );

    final userField = find.byKey(const Key("u_field"));
    expect(userField, findsOneWidget);

    final passwordField = find.byKey(const Key("p_field"));
    expect(passwordField, findsOneWidget);

    // Fill in the username and password fields
    await tester.enterText(userField, 'hello');
    await tester.enterText(passwordField, '18273645');

    // Tap the login button
    // ignore: unused_element

    await tester.tap(find.byKey(const Key("go_login")));
  });
}
