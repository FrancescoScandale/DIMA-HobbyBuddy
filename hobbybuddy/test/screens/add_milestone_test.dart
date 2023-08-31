import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final firestore = FakeFirebaseFirestore();
const String user = 'francesco';

//there were renderflex errors in mentors (Container and Column went outside borders)
//they were solved by wrapping the column in a SingleChildScrollView()
//reference of the solution: homepage_user.dart - row 328
void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: MockFirebaseStorage());

    //setup preferences
    SharedPreferences.setMockInitialValues({
      'username': 'francesco',
      'hobbies': ['Skateboard'],
      'mentors': ['Ben Affleck'],
      'email': '',
    });
    await Preferences.init();

    //setup fake firestore
    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': 'Frisbee,Badminton,Chess,Skateboard',
      'mentors': 'John Travolta,Ben Affleck',
      'name': 'Francesco',
      'surname': 'Scandale',
      'location': '45.4905447,9.2303139'
    });
    await firestore.collection('mentors').add({
      'name': 'Ben',
      'surname': 'Affleck',
      'hobby': 'Skateboard',
      'classes': ['1;;We\'ll try to achieve a kickflip!;;15/09/2023;;9:21']
    });

    //propic
    final Reference storageRefpropic =
        StorageCrud.getStorage().ref().child('Users/francesco/propic.jpg');
    final ByteData propic = await rootBundle.load("assets/pics/propic.jpg");
    await storageRefpropic.putData(propic.buffer.asUint8List());
    //background
    final Reference storageRefbackground =
        StorageCrud.getStorage().ref().child('Users/francesco/background.jpg');
    final ByteData background =
        await rootBundle.load("assets/pics/background.jpg");
    await storageRefbackground.putData(background.buffer.asUint8List());

    //mentors
    final Reference JTRefpropic = StorageCrud.getStorage()
        .ref()
        .child('Mentors/John Travolta/propic.jpg');
    final ByteData JTpropic = await rootBundle.load("assets/pics/propic.jpg");
    await JTRefpropic.putData(JTpropic.buffer.asUint8List());

    final Reference BARefpropic =
        StorageCrud.getStorage().ref().child('Mentors/Ben Affleck/propic.jpg');
    final ByteData BApropic = await rootBundle.load("assets/pics/propic.jpg");
    await BARefpropic.putData(BApropic.buffer.asUint8List());
    final Reference BARefbackground = StorageCrud.getStorage()
        .ref()
        .child('Mentors/Ben Affleck/background.jpg');
    final ByteData BAbackground =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await BARefbackground.putData(BAbackground.buffer.asUint8List());

    //milestone
    const String title = '2023-08-14_14:15:10';
    final Reference milestoneRefpic = StorageCrud.getStorage()
        .ref()
        .child('Users/francesco/milestones/$title/pic.jpg');
    final ByteData milestonePic =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await milestoneRefpic.putData(milestonePic.buffer.asUint8List());
    final Reference milestoneRefcaption = StorageCrud.getStorage()
        .ref()
        .child('Users/francesco/milestones/$title/caption.txt');
    const String caption = 'This is a caption';
    await milestoneRefcaption.putData(Uint8List.fromList(utf8.encode(caption)));
  });

  group('User homepage screen test', () {
    testWidgets('User\'s homepage renders correctly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: UserPage(
            user: 'francesco',
          ),
        ),
      );
      await tester.pumpAndSettle();

      //appBar
      expect(find.text('Profile Page'), findsOneWidget);

      //images (hobbies and others)
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is AssetImage,
              skipOffstage: false),
          findsNWidgets(4));
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is MemoryImage,
              skipOffstage: false),
          findsNWidgets(5));

      expect(find.byIcon(Icons.settings_sharp), findsOneWidget);
      expect(find.byType(MyButton), findsOneWidget);
    });

    testWidgets('User\'s homepage behavior', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: UserPage(
            user: 'francesco',
          ),
        ),
      );
      await tester.pumpAndSettle();

      //create navigator to go to previous screen
      final NavigatorState navigator = tester.state(find.byType(Navigator));

      //go to settings
      await tester.tap(find.byIcon(Icons.settings_sharp));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();

      // go to hobby
      await tester.tap(find.image(
          Image.asset('assets/hobbies/Skateboard.png').image,
          skipOffstage: true));
      await tester.pumpAndSettle();
      expect(find.text('Home Page Hobby'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();

      //go to mentor
      await tester.tap(find.byKey(const Key('Ben Affleck')));
      await tester.pumpAndSettle();
      expect(find.text('Mentor Page'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();

      // //go to add milestones
      await tester.tap(find.text('+ Milestone', skipOffstage: false));
      await tester.pumpAndSettle();
      expect(find.text('Add New Milestone'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
    });
  });
}
