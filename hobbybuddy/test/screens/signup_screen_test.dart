import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    SharedPreferences.setMockInitialValues({});
    await Preferences.init();
  });
  testWidgets('SignUpScreen displays form and handles sign-up', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is TextFormField),
      findsNWidgets(6),
    );
    expect(
      find.byWidgetPredicate((widget) => widget is MyButton),
      findsOneWidget,
    );
  });
}
