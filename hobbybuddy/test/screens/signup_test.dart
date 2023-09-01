import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    await firestore.collection("users").add({
      "username": "user1",
      "name": "user", // example received requests
      "surname": "surname2", // example sent requests
      "email": "email@user.it", // example friends
      "password": "userpassword",
    });
  });
  testWidgets('SignUpScreen displays form and handles sign-up', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(6),
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

    await tester.tap(find.byKey(const Key("signup_button")));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is AlertDialog),
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
      findsNWidgets(6),
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
      findsNWidgets(6),
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

    await tester.tap(find.byKey(const Key("signup_button")));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'This username is already taken. Please choose a different one.'),
        findsOneWidget);
  });
}
