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

  group('general navigation test', () {
    testWidgets('user can navigate to the friend_list page and refresh screen',
        (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await app.main();
      await tester.pumpAndSettle();

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

      //go to My friends page
      final userPage = find.byIcon(Icons.groups);
      expect(userPage, findsOneWidget);
      await tester.tap(userPage);
      await tester.pumpAndSettle(Duration(seconds: 8));

      final slide = find.text("Explore");
      expect(slide, findsOneWidget);
      await tester.tap(slide);
      await tester.pumpAndSettle(Duration(seconds: 8));

      var user = find.text("BiBi");
      const offset2 = Offset(0, 300);
      await tester.fling(
        user,
        offset2,
        1000,
        warnIfMissed: false,
      );
      await tester.pump();
      expect(
          tester.getSemantics(find.byType(RefreshProgressIndicator)),
          matchesSemantics(
            label: 'Refresh',
          ));

      await tester
          .pump(const Duration(seconds: 1)); // finish the scroll animation
      await tester.pump(
          const Duration(seconds: 1)); // finish the indicator settle animation
      await tester.pump(
          const Duration(seconds: 1)); // finish the indicator hide animation
      handle.dispose();
    });

    testWidgets(
        'user can navigate to hobby and then to mentor to visualize an available tutorial',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();

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

      //go to skateboard home page
      final hobby = find.text("Skateboard");
      expect(hobby, findsOneWidget);
      await tester.tap(hobby);
      await tester.pumpAndSettle(Duration(seconds: 3));

      //unlike hobby
      final unlike = find.byIcon(Icons.favorite).first;
      expect(unlike, findsOneWidget);
      await tester.tap(unlike);
      await tester.pumpAndSettle(Duration(seconds: 3));
      //relike hobby
      final like = find.byIcon(Icons.favorite_border).first;
      expect(like, findsOneWidget);
      await tester.tap(like);
      await tester.pumpAndSettle(Duration(seconds: 3));

      //go to mentor page
      final mentor = find.text("Ben Affleck");
      expect(mentor, findsOneWidget);
      await tester.tap(mentor);
      await tester.pumpAndSettle(Duration(seconds: 10));

      //unlike mentor
      final unlike2 = find.byIcon(Icons.favorite);
      expect(unlike2, findsOneWidget);
      await tester.tap(unlike2);
      await tester.pumpAndSettle(Duration(seconds: 3));
      //relike mentor
      final like2 = find.byIcon(Icons.favorite_border);
      expect(like2, findsOneWidget);
      await tester.tap(like2);
      await tester.pumpAndSettle(Duration(seconds: 5));

      //tap on a course
      var minFinder = find.text("Courses").first;
      const offset = Offset(0, -150);
      await tester.fling(
        minFinder,
        offset,
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(Duration(seconds: 5));
      final course = find.text("Technique basics");
      expect(course, findsOneWidget);
      await tester.tap(course);
      await tester.pumpAndSettle(Duration(seconds: 8));

      //go back to home page via cupertinoBottomNavigationBar
      final homePage = find.byIcon(Icons.home);
      expect(homePage, findsOneWidget);
      await tester.tap(homePage);
      await tester.pumpAndSettle(Duration(seconds: 8));
    });
    testWidgets(
        'user can navigate to the user page, then settings to modify accounto info and preferences',
        (tester) async {
      await app.main();
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle(Duration(seconds: 8));

      //go to user home page
      final userPage = find.byIcon(Icons.account_circle);
      expect(userPage, findsOneWidget);
      await tester.tap(userPage);
      await tester.pumpAndSettle(Duration(seconds: 10));

      //go to user settings
      final settingsPage = find.byIcon(Icons.settings_sharp);
      expect(settingsPage, findsOneWidget);
      await tester.tap(settingsPage);
      await tester.pumpAndSettle(Duration(seconds: 5));

      final dark = find.text("Dark mode");
      expect(dark, findsOneWidget);
      await tester.tap(dark);
      await tester.pumpAndSettle(Duration(seconds: 3));

      //navigate to edit profile
      final edit = find.text("Edit profile");
      expect(edit, findsOneWidget);
      await tester.tap(edit);
      await tester.pumpAndSettle(Duration(seconds: 3));
      final nameField = find.byKey(const Key("newName"));
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, "martaNew");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 3));
      final buttonToTap = find.byKey(const Key('saveB'));
      await tester.tap(buttonToTap);
      await tester.pumpAndSettle(Duration(seconds: 5));

      //go to change password
      final changeP = find.text("Change password");
      expect(changeP, findsOneWidget);
      await tester.tap(changeP);
      await tester.pumpAndSettle(Duration(seconds: 3));

      final password = find.byKey(Key("currentP"));
      expect(password, findsOneWidget);
      await tester.enterText(password, "876545678");

      final newP = find.byKey(Key("newP"));
      expect(newP, findsOneWidget);
      await tester.enterText(newP, "87654321");

      final newP2 = find.byKey(Key("newP2"));
      expect(newP2, findsOneWidget);
      await tester.enterText(newP2, "87654321");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 3));

      final save = find.text("Save");
      final ok = find.text("OK");
      expect(save, findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle(Duration(seconds: 3));
      expect(find.text("The password is not correct."), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 3));
      await tester.tap(ok);
      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(password, findsOneWidget);
      await tester.enterText(password, "12345678");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 3));

      expect(save, findsOneWidget);
      await tester.tap(save);
      await tester.pumpAndSettle(Duration(seconds: 3));
      expect(find.text("Your password has been changed successfully."),
          findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 3));
      await tester.tap(ok);
      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(userPage, findsOneWidget);
      await tester.tap(userPage);
      await tester.pumpAndSettle(Duration(seconds: 10));
    });
  });
}
