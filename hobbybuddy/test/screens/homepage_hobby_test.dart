import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/firebase_options.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();
final storage = MockFirebaseStorage();

class MockFirebaseCrud extends Mock implements FirebaseCrud {}

void main() async {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
    );
    
    SharedPreferences.setMockInitialValues({
      'flutter.isDark': true,
      'flutter.username': 'francesco',
      'flutter.hobbies': [],
      'flutter.mentors': [],
    });
    await Preferences.init();
  });

  testWidgets('HomePage hobby', (tester) async {
    const String hobby = 'Skateboard';
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FirebaseCrud>(
            create: (context) => MockFirebaseCrud(),
          ),
          Provider<FirebaseStorage>(
            create: (context) => storage,
          ),
        ],
        child: const MaterialApp(
          home: HomePageHobby(
            hobby: hobby,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byElementType(Image),
      //find.byWidgetPredicate((widget) => widget is TextFormField),
      findsOneWidget,
    );
    // expect(
    //   find.byWidgetPredicate((widget) => widget is MyButton),
    //   findsOneWidget,
    // );
  });
}
