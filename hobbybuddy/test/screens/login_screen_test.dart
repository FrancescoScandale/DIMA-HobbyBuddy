import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/login.dart';
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
    SharedPreferences.setMockInitialValues({
      'username': 'marta',
      'name': 'marta',
      'surname': 'radaelli',
    });
    await firestore
        .collection("users")
        .add({'username': 'marta', 'password': '12345678'});
  });
  testWidgets('LogInScreen renders correctly with button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LogInScreen(),
      ),
    );

    final userField = find.byKey(const Key("u_field"));
    expect(userField, findsOneWidget);

    final passwordField = find.byKey(const Key("p_field"));
    expect(passwordField, findsOneWidget);

    final button = find.byKey(const Key("go_login"));
    expect(button, findsOneWidget);

    // Fill in the username and password fields
    await tester.enterText(userField, 'marta');
    await tester.enterText(passwordField, '12345678');

    // Tap the login button
    await tester.tap(button);
    await tester.pumpAndSettle();
  });
}
