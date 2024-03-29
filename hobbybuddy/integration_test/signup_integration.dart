import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbybuddy/main.dart' as app;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:hobbybuddy/services/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

final firestore = FakeFirebaseFirestore();
final mockAuth = MockFirebaseAuth();

String usernameTest = 'abcde';
final mockLocation = Location(
  latitude: 45.4904447,
  longitude: 9.2301139,
  timestamp: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
);

final mockPlacemark = Placemark(
  locality: 'Milano',
  street: 'Via San Pietro All\'Orto, 7',
);

Future tapOnWidgetByKey({
  required String key,
  required WidgetTester tester,
}) async {
  final widget = find.byKey(Key(key));
  expect(widget, findsOneWidget);
  await tester.tap(widget);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    GeocodingPlatform.instance = MockGeocodingPlatform();
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    AuthenticationCrud.init(authInstance: mockAuth);
    await firestore.collection("users").add({
      "username": "user",
      "name": "user",
      "surname": "surname2",
      "email": "email@user.it",
      "location": "45.4905447,9.2303139",
    });
  });

  group('sign up test', () {
    testWidgets('sign up new user and login', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "go_sign_up", tester: tester);

      //in signup
      final userForm = find.byKey(Key("username_field"));
      expect(userForm, findsOneWidget);
      await tester.enterText(userForm, usernameTest);

      final nameForm = find.byKey(Key("name_field"));
      expect(nameForm, findsOneWidget);
      await tester.enterText(nameForm, "nameNew");

      final surnameForm = find.byKey(Key("surname_field"));
      expect(surnameForm, findsOneWidget);
      await tester.enterText(surnameForm, "surnameNew");

      final emailForm = find.byKey(Key("email_field"));
      expect(emailForm, findsOneWidget);
      await tester.enterText(emailForm, "newuser@testmail.it");

      final passwordForm = find.byKey(Key("password_field"));
      expect(passwordForm, findsOneWidget);
      await tester.enterText(passwordForm, "12345678");

      final password2Form = find.byKey(Key("password_confirm_field"));
      expect(password2Form, findsOneWidget);
      await tester.enterText(password2Form, "12345678");

      final location = find.byKey(const Key("location_field"));
      expect(location, findsOneWidget);
      await tester.enterText(location, 'Via San Pietro All\'Orto, 7, Milano');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap the signup button
      final signupButton = find.byKey(Key("signup_button"));
      expect(signupButton, findsOneWidget);
      await tester.tap(signupButton);
      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(
        find.byWidgetPredicate((widget) => widget is AlertDialog),
        findsNWidgets(1),
      );
      await tester.tap(find.text('Back to Main Page'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // We are in login, verify that the signup process was successful.
      final user2Form = find.byKey(Key("u_field"));
      expect(user2Form, findsOneWidget);
      await tester.enterText(user2Form, usernameTest);

      final password3Form = find.byKey(Key("p_field"));
      expect(password3Form, findsOneWidget);
      await tester.enterText(password3Form, "12345678");

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 1));

      final loginButton = find.byKey(Key("go_login"));
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(Duration(seconds: 5));
    });

    testWidgets('sign up old user', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await tapOnWidgetByKey(key: "go_sign_up", tester: tester);

      //in signup
      final userForm = find.byKey(Key("username_field"));
      expect(userForm, findsOneWidget);
      await tester.enterText(userForm, usernameTest);

      final nameForm = find.byKey(Key("name_field"));
      expect(nameForm, findsOneWidget);
      await tester.enterText(nameForm, "nameNew");

      final surnameForm = find.byKey(Key("surname_field"));
      expect(surnameForm, findsOneWidget);
      await tester.enterText(surnameForm, "surnameNew");

      final emailForm = find.byKey(Key("email_field"));
      expect(emailForm, findsOneWidget);
      await tester.enterText(emailForm, "newuser@testmail.it");

      final passwordForm = find.byKey(Key("password_field"));
      expect(passwordForm, findsOneWidget);
      await tester.enterText(passwordForm, "12345678");

      final password2Form = find.byKey(Key("password_confirm_field"));
      expect(password2Form, findsOneWidget);
      await tester.enterText(password2Form, "12345678");

      final location = find.byKey(const Key("location_field"));
      expect(location, findsOneWidget);
      await tester.enterText(location, 'Via San Pietro All\'Orto, 7, Milano');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Tap the signup button
      final signupButton = find.byKey(Key("signup_button"));
      expect(signupButton, findsOneWidget);
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      var successDuplicateWarning = find.text(
          'This username is already taken. Please choose a different one.',
          skipOffstage: false); // Wait for the Snackbar to appear
      await tester.pump(const Duration(seconds: 3));
      expect(successDuplicateWarning, findsAtLeastNWidgets(1));
      await tester.pumpAndSettle();
    });
  });
}

class MockGeocodingPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeocodingPlatform {
  @override
  Future<List<Location>> locationFromAddress(
    String address, {
    String? localeIdentifier,
  }) async {
    return [mockLocation];
  }

  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    return [mockPlacemark];
  }
}
