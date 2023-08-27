import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';

final firestore = FakeFirebaseFirestore();
final storage = MockFirebaseStorage();

class MockFirebaseCrud extends Mock implements FirebaseCrud {}

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      'username': 'marta',
      'name': 'marta',
      'surname': 'radaelli',
    });
    await firestore.collection("users").add({
      'username': 'marta',
    });
    const filename = 'logo.png';
    final storageRef = storage.ref().child(filename);
    final localImage = await rootBundle.load("assets/$filename");
    final task = await storageRef.putData(localImage.buffer.asUint8List());
    print(task.ref.fullPath);
  });

  group('Settings screen test', () {
    testWidgets('EditProfileScreen renders correctly', (tester) async {
      await Preferences.init();
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
