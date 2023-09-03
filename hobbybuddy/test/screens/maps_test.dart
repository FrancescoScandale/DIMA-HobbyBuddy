import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobbybuddy/screens/maps.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import '../mock/fake_maps_platform.dart';

final firestore = FakeFirebaseFirestore();

void main() async {
  late FakeGoogleMapsFlutterPlatform platform;
  setUp(() async {
    FirestoreCrud.init(firebaseInstance: firestore);
    WidgetsFlutterBinding.ensureInitialized();
    StorageCrud.init(storageInstance: MockFirebaseStorage());
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;

    SharedPreferences.setMockInitialValues({
      'isDark': true,
      'username': 'francesco',
      'hobbies': ['Skateboard', 'Chess'],
      'location': ['45.466050', '9.190740']
    });
    await Preferences.init();

    await firestore.collection('users').add({
      'username': 'francesco',
      'location': '45.466050,9.190740',
      'hobbies': 'Skateboard,Chess'
    });

    await firestore.collection('mentors').add({
      'name': 'Ben',
      'surname': 'Affleck',
      'hobby': 'Skateboard',
      'classes': ['1;;Kickflip class;;15/09/2023;;9:21']
    });

    await firestore.collection('mentors').add({
      'name': 'Lewis',
      'surname': 'Hamilton',
      'hobby': 'Frisbee',
    });

    await firestore.collection('mentors').add({
      'name': 'Emma',
      'surname': 'Watson',
      'hobby': 'Chess',
    });

    await firestore.collection('mentors').add({
      'name': 'John',
      'surname': 'Travolta',
      'hobby': 'Chess',
    });

    await firestore.collection('markers').add({
      'lat': '45.466050',
      'lng': '9.190730',
      'mentor': 'Ben Affleck',
      'title': 'Skateboard'
    });

    await firestore.collection('markers').add({
      'lat': '45.466050',
      'lng': '9.190720',
      'mentor': 'John Travolta',
      'title': 'Chess'
    });

    await firestore.collection('markers').add({
      'lat': '45.466050',
      'lng': '9.190710',
      'mentor': 'Lewis Hamilton',
      'title': 'Frisbee'
    });

    final Reference refPropic =
        StorageCrud.getStorage().ref().child('Mentors/Ben Affleck/propic.jpg');
    final ByteData propic = await rootBundle.load("assets/pics/propic.jpg");
    await refPropic.putData(propic.buffer.asUint8List());
    final Reference refBackground = StorageCrud.getStorage()
        .ref()
        .child('Mentors/Ben Affleck/background.jpg');
    final ByteData background =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await refBackground.putData(background.buffer.asUint8List());

    //course summary
    final Reference courseRefPic = StorageCrud.getStorage()
        .ref()
        .child('Mentors/Ben Affleck/courses/2023-08-14_14:15:10/pic.jpg');
    final ByteData coursePic =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await courseRefPic.putData(coursePic.buffer.asUint8List());
    final Reference courseRefCaption = StorageCrud.getStorage()
        .ref()
        .child('Mentors/Ben Affleck/courses/2023-08-14_14:15:10/title.txt');
    const String title = '3;;Title of Course';
    await courseRefCaption.putData(Uint8List.fromList(utf8.encode(title)));
  });

  group('Map page screen test', () {
    testWidgets('Map page renders and behaves correctly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(home: MapsScreen()),
      );
      await tester.pumpAndSettle();

      //appBar
      expect(
        find.text('Buddy Finder'),
        findsOneWidget,
      );

      // buttons
      expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton),
          findsNWidgets(2));
      var back = find.text('Go Back Home');
      expect(back, findsOneWidget);
      expect(find.text('Reload Hobbies'), findsOneWidget);

      //map
      expect(find.byType(GoogleMap), findsOneWidget);
      var map = tester.firstWidget(find.byType(GoogleMap)) as GoogleMap;
      map.onMapCreated;

      //markers
      await tester.pumpAndSettle();
      GoogleMap gm = tester.widget(find.byType(GoogleMap)) as GoogleMap;
      assert(gm.markers.length == 2);

      await tester.tap(back);
      await tester.pumpAndSettle();

      String id = '';
      await firestore
          .collection("users")
          .where("username", isEqualTo: 'francesco')
          .get()
          .then((value) => id = value.docs[0].id);
      await firestore.collection("users").doc(id).update({'hobbies': 'Chess'});
      await Preferences.setHobbies('francesco');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reload Hobbies'));
      await tester.pumpAndSettle();
      gm = tester.widget(find.byType(GoogleMap)) as GoogleMap;
      assert(gm.markers.length == 1);
    });
  });
}
