import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();

void main() async {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues({
      'isDark': true,
      'username': 'francesco',
      'hobbies': ['Skateboard', 'Chess'],
      'mentors': ['Emma Watson'],
    });
    await Preferences.init();

    FirebaseCrud.init(firestore);
    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': ['Skateboard'],
      'mentors': ['Emma Watson'],
    });
  });

  testWidgets('HomePage hobby', (tester) async {
    const String hobby = 'Skateboard';
    await tester.pumpWidget(
      MaterialApp(
        home: HomePageHobby(
          hobby: hobby,
        ),
      ),
    );

    expect(
      find.text('Skateboard'),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate((widget) => widget is Image),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate((widget) => widget is MyIconButton),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.favorite),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.favorite));

    await tester.pump();
    expect(
      find.byIcon(Icons.favorite_border),
      findsOneWidget,
    );
  });
}
