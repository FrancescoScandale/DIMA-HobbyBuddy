import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';

final firestore = FakeFirebaseFirestore();

void main() async {
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
    await firestore.collection("users").add({
      'username': 'marta',
    });
    //propic
    final Reference storageRefpropic =
        StorageCrud.getStorage().ref().child('Users/marta/propic.jpg');
    final ByteData propic = await rootBundle.load("assets/pics/propic.jpg");
    await storageRefpropic.putData(propic.buffer.asUint8List());
    //background
    final Reference storageRefbackground =
        StorageCrud.getStorage().ref().child('Users/marta/background.jpg');
    final ByteData background =
        await rootBundle.load("assets/pics/background.jpg");
    await storageRefbackground.putData(background.buffer.asUint8List());
  });

  group('Settings screen test', () {
    testWidgets('EditProfileScreen renders correctly', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the AppBar title is correct.
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(
        find.byType(Image),
        findsNWidgets(2),
      );
      final backgroundImage = find.byKey(const Key("backgImage"));
      expect(backgroundImage, findsOneWidget);
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .first);
      await tester.pumpAndSettle();
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close)
          .first);
      await tester.pumpAndSettle();
      expect(
        find.byType(ClipRRect),
        findsNWidgets(1),
      );
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .last);
      await tester.pumpAndSettle();
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close)
          .last);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Icon && widget.icon == Icons.photo_camera),
        findsNWidgets(2),
      );
      // Find TextFormField widgets
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      );

      await tester.tap(find.text("Save"));
      expect(find.text('Loading...'), findsOneWidget);
    });
  });
}
