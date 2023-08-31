import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobbybuddy/screens/homepage_mentor.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';

final firestore = FakeFirebaseFirestore();
String mentor = 'Ben Affleck';

//there were renderflex errors in the ListViews (Container and Column went outside borders)
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
      'mentors': [mentor],
      'email': '',
    });
    await Preferences.init();

    //setup fake firestore
    await firestore.collection('mentors').add({
      'name': mentor.split(' ')[0],
      'surname': mentor.split(' ')[1],
      'hobby': 'Skateboard',
      'classes': ['1;;Kickflip class;;15/09/2023;;9:21']
    });
    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': 'Skateboard',
      'mentors': mentor,
    });

    final Reference refPropic =
        StorageCrud.getStorage().ref().child('Mentors/$mentor/propic.jpg');
    final ByteData propic = await rootBundle.load("assets/pics/propic.jpg");
    await refPropic.putData(propic.buffer.asUint8List());
    final Reference refBackground =
        StorageCrud.getStorage().ref().child('Mentors/$mentor/background.jpg');
    final ByteData background =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await refBackground.putData(background.buffer.asUint8List());

    //course summary
    final Reference courseRefPic = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/2023-08-14_14:15:10/pic.jpg');
    final ByteData coursePic =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await courseRefPic.putData(coursePic.buffer.asUint8List());
    final Reference courseRefCaption = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/2023-08-14_14:15:10/title.txt');
    const String title = '3;;Title of Course';
    await courseRefCaption.putData(Uint8List.fromList(utf8.encode(title)));

    //course page
    // final Reference courseRefText = StorageCrud.getStorage()
    //     .ref()
    //     .child('Mentors/$mentor/courses/2023-08-14_14:15:10/title.txt');
    // const String text = 'Text and explanation of the course.';
    // await courseRefText.putData(Uint8List.fromList(utf8.encode(text)));
    // final Reference courseRefPic1 = StorageCrud.getStorage()
    //     .ref()
    //     .child('Mentors/$mentor/courses/2023-08-14_14:15:10/picture1.jpg');
    // final ByteData coursePic1 =
    //     await rootBundle.load("assets/pics/background.jpg");
    // await courseRefPic1.putData(coursePic1.buffer.asUint8List());
  });

  group('Mentor homepage screen test', () {
    testWidgets('Mentor\'s homepage renders correctly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        MaterialApp(
          home: MentorPage(
            mentor: mentor,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //appBar
      expect(find.text('Mentor Page'), findsOneWidget);

      //texts
      expect(find.text(mentor), findsOneWidget);
      expect(find.text('Skateboard', skipOffstage: false), findsOneWidget);
      expect(
          find.text('Upcoming Classes', skipOffstage: false), findsOneWidget);
      expect(find.text('Courses', skipOffstage: false), findsOneWidget);
      expect(find.text('Kickflip class', skipOffstage: false), findsOneWidget);
      expect(find.text('Title of Course', skipOffstage: false), findsOneWidget);

      //images (classes' difficulties and others)
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is AssetImage,
              skipOffstage: false),
          findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is MemoryImage,
              skipOffstage: false),
          findsNWidgets(3));

      //favourite and course
      expect(find.byType(MyIconButton), findsNWidgets(2));
    });

    //expect(find.byIcon(Icons.favorite), findsOneWidget);

    testWidgets('Mentor\'s homepage behavior', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        MaterialApp(
          home: MentorPage(
            mentor: mentor,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //create navigator to go to previous screen
      final NavigatorState navigator = tester.state(find.byType(Navigator));

      //toggle mentor like
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      assert(!Preferences.getMentors()!.contains(mentor));

      //go to course
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is MyIconButton && widget.icon is ContainerShadow,
          skipOffstage: false));
      await tester.pumpAndSettle();
      expect(find.text('Course Page'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
    });
  });
}
