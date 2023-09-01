import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hobbybuddy/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final firestore = FakeFirebaseFirestore();
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: MockFirebaseStorage());
  });

  group('login test', () {
    testWidgets('login fail', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      //await logoutTest(tester: tester);

      // We are in login, verify that the signup process was successful.
      final userForm = find.byKey(Key("u_field"));
      expect(userForm, findsOneWidget);
      await tester.enterText(userForm, "zxcv");

      final passwordForm = find.byKey(Key("p_field"));
      expect(passwordForm, findsOneWidget);
      await tester.enterText(passwordForm, "random");

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 1));

      final loginButton = find.byKey(Key("go_login"));
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(Duration(seconds: 1));
      final successSnackbar = find.text('Account not found...');
      await tester.pump(const Duration(seconds: 3));
      expect(successSnackbar, findsAtLeastNWidgets(1));
    });

    testWidgets('login and sign out success', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      //await logoutTest(tester: tester);

      // We are in login, verify that the signup process was successful.
      final userForm = find.byKey(Key("u_field"));
      expect(userForm, findsOneWidget);
      await tester.enterText(userForm, "marta");

      final passwordForm = find.byKey(Key("p_field"));
      expect(passwordForm, findsOneWidget);
      await tester.enterText(passwordForm, "12345678");

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 1));

      final loginButton = find.byKey(Key("go_login"));
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(Duration(seconds: 5));

      final userPage = find.byIcon(Icons.account_circle);
      expect(userPage, findsOneWidget);
      await tester.tap(userPage);
      await tester.pumpAndSettle(Duration(seconds: 5));
      final settingsPage = find.byIcon(Icons.settings_sharp);
      expect(settingsPage, findsOneWidget);
      await tester.tap(settingsPage);
      await tester.pumpAndSettle(Duration(seconds: 5));
      final signout = find.byType(ElevatedButton);
      expect(signout, findsOneWidget);
      await tester.tap(signout);
      await tester.pumpAndSettle(Duration(seconds: 2));
    });
  });
}
