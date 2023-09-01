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
    testWidgets('general navigation success', (tester) async {
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
    });
  });
}
