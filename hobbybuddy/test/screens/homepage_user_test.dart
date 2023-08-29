import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
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
      'username': 'francesco',
    });
    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': 'Frisbee,Badminton,Chess,Skateboard',
      'mentors': 'Orlando Bloom,John Travolta,Ben Affleck',
      'name': 'Francesco',
      'surname': 'Scandale',
      'location': '45.4905447,9.2303139'
    });

    //propic
    final Reference storageRefpropic = StorageCrud.getStorage().ref().child('Users/francesco/propic.jpg');
    final ByteData propic = await rootBundle.load("assets/pics/propic.jpg");
    await storageRefpropic.putData(propic.buffer.asUint8List());
    //background
    final Reference storageRefbackground = StorageCrud.getStorage().ref().child('Users/francesco/background.jpg');
    final ByteData background = await rootBundle.load("assets/pics/background.jpg");
    await storageRefbackground.putData(background.buffer.asUint8List());
    //milestone
    const String title = '2023-08-14_14:15:10';
    final Reference milestoneRefpic = StorageCrud.getStorage().ref().child('Users/francesco/milestones/$title/pic.jpg');
    final ByteData milestonePic = await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await milestoneRefpic.putData(milestonePic.buffer.asUint8List());
    final Reference milestoneRefcaption =
        StorageCrud.getStorage().ref().child('Users/francesco/milestones/$title/caption.txt');
    const String caption = 'This is a caption';
    await milestoneRefcaption.putData(Uint8List.fromList(utf8.encode(caption)));
  });

  group('Settings screen test', () {
    testWidgets('EditProfileScreen renders correctly', (tester) async {
      await Preferences.init();
      await tester.pumpWidget(
        const MaterialApp(
          home: UserPage(
            user: 'francesco',
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Verify that the AppBar title is correct.
      expect(find.text('Profile Page'), findsOneWidget);
      await tester.pumpAndSettle();
      // Find Image widgets
      expect(
        find.byType(Image),
        findsNWidgets(2),
      );
    });
  });
}
