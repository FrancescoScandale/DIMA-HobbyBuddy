import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/change_password.dart';
import 'package:hobbybuddy/services/firebase_auth.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();

final mockAuth = MockFirebaseAuth();

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    AuthenticationCrud.init(authInstance: mockAuth);
    mockAuth.createUserWithEmailAndPassword(
        email: 'test@gmail.com', password: '12345678');
    mockAuth.signInWithEmailAndPassword(
        email: 'test@gmail.com', password: '12345678');
    SharedPreferences.setMockInitialValues({'username': 'marta'});
    await firestore
        .collection("users")
        .add({'username': 'marta', 'password': '12345678'});

    await Preferences.init();
  });
  testWidgets(
      'ChangePassword Screen displays form and handles a correct change',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(3),
    );
    final currentP = find.byKey(const Key("currentP"));

    await tester.tap(find.byKey(const Key("lock1")));
    await tester.pumpAndSettle();
    expect(currentP, findsOneWidget);

    final newP = find.byKey(const Key("newP"));
    expect(newP, findsOneWidget);
    await tester.tap(find.byKey(const Key("lock2")));
    await tester.pumpAndSettle();

    final newP2 = find.byKey(const Key("newP2"));
    expect(newP2, findsOneWidget);
    await tester.tap(find.byKey(const Key("lock3")));
    await tester.pumpAndSettle();

    await tester.enterText(currentP, '12345678');
    await tester.enterText(newP, '87654321');
    await tester.enterText(newP2, '87654321');

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is MyButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your password has been changed successfully.'),
        findsOneWidget);
    await tester.tap(find.text("OK"));
  });

  testWidgets('ChangePassword Screen displays form and handles a wrong change',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(3),
    );
    final currentP = find.byKey(const Key("currentP"));
    expect(currentP, findsOneWidget);
    final newP = find.byKey(const Key("newP"));
    expect(newP, findsOneWidget);
    final newP2 = find.byKey(const Key("newP2"));
    expect(newP2, findsOneWidget);

    await tester.enterText(currentP, '12345678');
    await tester.enterText(newP, '12345555');
    await tester.enterText(newP2, '12347546354');

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is MyButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('ChangePassword Screen displays form and handles a wrong change',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(3),
    );
    final currentP = find.byKey(const Key("currentP"));
    expect(currentP, findsOneWidget);
    final newP = find.byKey(const Key("newP"));
    expect(newP, findsOneWidget);
    final newP2 = find.byKey(const Key("newP2"));
    expect(newP2, findsOneWidget);

    await tester.enterText(currentP, '12333');
    await tester.enterText(newP, '123');
    await tester.enterText(newP2, '1354');

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is MyButton),
    );
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 8 characters long'),
        findsNWidgets(2));
  });
}
