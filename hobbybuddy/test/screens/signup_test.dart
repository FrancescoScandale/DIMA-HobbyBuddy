import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

final firestore = FakeFirebaseFirestore();

final mockLocation = Location(
  latitude: 45.4904447,
  longitude: 9.2301139,
  timestamp: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
);

final mockPlacemark = Placemark(
  locality: 'Milano',
  street: 'Via Cavour 7',
);
void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    GeocodingPlatform.instance = MockGeocodingPlatform();
    await firestore.collection("users").add({
      "username": "user1",
      "name": "user", // example received requests
      "surname": "surname2", // example sent requests
      "email": "email@user.it", // example friends
      "password": "userpassword",
    });
  });
  testWidgets('SignUpScreen displays form and handles a correct sign-up',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(7),
    );
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is TextButton),
      findsNWidgets(1),
    );

    final userField = find.byKey(const Key("username_field"));
    expect(userField, findsOneWidget);
    await tester.enterText(userField, 'testUser');

    final nameField = find.byKey(const Key("name_field"));
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'name');

    final surnameField = find.byKey(const Key("surname_field"));
    expect(surnameField, findsOneWidget);
    await tester.enterText(surnameField, 'surname');

    final emailField = find.byKey(const Key("email_field"));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'email@google.com');

    final passwordField = find.byKey(const Key("password_field"));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, '12345678');

    final password2Field = find.byKey(const Key("password_confirm_field"));
    expect(password2Field, findsOneWidget);
    await tester.enterText(password2Field, '12345678');

    final location = find.byKey(const Key("location_field"));
    expect(location, findsOneWidget);
    await tester.enterText(location, 'Via Cavour 7, Milano');

    await tester.tap(find.byKey(const Key("signup_button")));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is AlertDialog,
          skipOffstage: false),
      findsNWidgets(1),
    );

    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              widget.image.toString().contains('logo.png'),
        ),
        findsOneWidget);
    expect(find.text('Thank you for joining Hobby Hobby!'), findsOneWidget);
    expect(find.text('You can now go back to the main page to log in.'),
        findsOneWidget);
    await tester.tap(find.text('Back to Main Page'));
    await tester.pumpAndSettle();
  });

  testWidgets('SignUpScreen handles empty fields and mismatched passwords',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(7),
    );

    final userField = find.byKey(const Key("username_field"));
    expect(userField, findsOneWidget);
    await tester.enterText(userField, 'user1');

    final nameField = find.byKey(const Key("name_field"));
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, '');

    final surnameField = find.byKey(const Key("surname_field"));
    expect(surnameField, findsOneWidget);
    await tester.enterText(surnameField, '');

    final emailField = find.byKey(const Key("email_field"));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, '');

    final passwordField = find.byKey(const Key("password_field"));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, '1234567');

    final password2Field = find.byKey(const Key("password_confirm_field"));
    expect(password2Field, findsOneWidget);
    await tester.enterText(password2Field, '87654321');

    final location = find.byKey(const Key("location_field"));
    expect(location, findsOneWidget);
    await tester.enterText(location, 'Via Cavour 7, Milano');

    expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    await tester.tap(find.byType(IconButton).first);
    await tester.tap(find.byType(IconButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("signup_button")));
    await tester.pumpAndSettle();
    expect(find.text('Name cannot be empty'), findsOneWidget);
    expect(find.text('Surname cannot be empty'), findsOneWidget);
    expect(find.text('Please enter an e-mail address'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters long'),
        findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('SignUpScreen rejects already existing username', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(7),
    );

    final userField = find.byKey(const Key("username_field"));
    expect(userField, findsOneWidget);
    await tester.enterText(userField, 'user1');

    final nameField = find.byKey(const Key("name_field"));
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'a');

    final surnameField = find.byKey(const Key("surname_field"));
    expect(surnameField, findsOneWidget);
    await tester.enterText(surnameField, 'b');

    final emailField = find.byKey(const Key("email_field"));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'ab@live.it');

    final passwordField = find.byKey(const Key("password_field"));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, '12345678');

    final password2Field = find.byKey(const Key("password_confirm_field"));
    expect(password2Field, findsOneWidget);
    await tester.enterText(password2Field, '12345678');

    final location = find.byKey(const Key("location_field"));
    expect(location, findsOneWidget);
    await tester.enterText(location, 'Via Cavour 7, Milano');

    await tester.tap(find.byKey(const Key("signup_button")));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'This username is already taken. Please choose a different one.',
            skipOffstage: false),
        findsOneWidget);
  });

  testWidgets('Go back to login screen', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);

    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();

    final back = find.byWidgetPredicate((widget) => widget is TextButton);
    await tester.tap(back);
    await tester.pumpAndSettle();
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
