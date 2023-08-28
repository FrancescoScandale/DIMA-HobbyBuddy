import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';

final firestore = FakeFirebaseFirestore();
final storage = MockFirebaseStorage();

class MockFirebaseCrud extends Mock implements FirestoreCrud {}

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: storage);

    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      'username': 'marta',
      'name': 'marta',
      'surname': 'radaelli',
    });
    await firestore.collection("users").add({
      'username': 'marta',
    });
    final storageRefpropic = storage.ref().child('Users/marta/propic.jpg');
    final storageRefbackground = storage.ref().child('Users/marta/background.jpg');
    final localImage = await rootBundle.load("assets/logo.png");
    final task = await storageRefpropic.putData(localImage.buffer.asUint8List());
    final task2 = await storageRefbackground.putData(localImage.buffer.asUint8List());
    print(task.ref.fullPath);
    print(task2.ref.fullPath);
  });

  group('Settings screen test', () {
    testWidgets('EditProfileScreen renders correctly', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<FirestoreCrud>(
              create: (context) => MockFirebaseCrud(),
            ),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Verify that the AppBar title is correct.
      expect(find.text('Edit Profile'), findsOneWidget);

      // Find TextFormField widgets
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      );
    });
  });
}
