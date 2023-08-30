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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final firestore = FakeFirebaseFirestore();

final mockLocation = Location(
  latitude: 45.4904447,
  longitude: 9.2301139,
  timestamp: DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
);

final mockPlacemark = Placemark(
  // administrativeArea: 'Overijssel',
  // country: 'Netherlands',
  // isoCountryCode: 'NL',
  locality: 'Milano',
  // name: 'Gronausestraat',
  // postalCode: '',
  street: 'Via Cavour 7',
  // subAdministrativeArea: 'Enschede',
  // subLocality: 'Enschmarke',
  // subThoroughfare: '',
  // thoroughfare: 'Gronausestraat'
);

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: MockFirebaseStorage());
    GeocodingPlatform.instance = MockGeocodingPlatform();

    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      'username': 'francesco',
      'hobbies': [],
      'mentors': [],
      'email': '',
    });
    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': 'Frisbee,Badminton,Chess,Skateboard',
      'mentors': 'John Travolta,Ben Affleck',
      'name': 'Francesco',
      'surname': 'Scandale',
      'location': '45.4905447,9.2303139'
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
    final Reference JTRefpropic = StorageCrud.getStorage().ref().child('Mentors/John Travolta/propic.jpg');
    final ByteData JTpropic = await rootBundle.load("assets/pics/propic.jpg");
    await JTRefpropic.putData(JTpropic.buffer.asUint8List());
    final Reference BFRefpropic = StorageCrud.getStorage().ref().child('Mentors/Ben Affleck/propic.jpg');
    final ByteData BFpropic = await rootBundle.load("assets/pics/propic.jpg");
    await BFRefpropic.putData(BFpropic.buffer.asUint8List());
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

// ignore: prefer_mixin
class MockGeocodingPlatform extends Mock with MockPlatformInterfaceMixin implements GeocodingPlatform {
  // with
  //     // ignore: prefer_mixin
  //     MockPlatformInterfaceMixin
  // implements
  //     GeocodingPlatform {
  @override
  Future<List<Location>> locationFromAddress(
    String address, {
    String? localeIdentifier,
  }) async {
    return [mockLocation];
  }

  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    return [mockPlacemark];
  }
}
