import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobbybuddy/screens/courses.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:video_player/video_player.dart';

const String mentor = 'Ben Affleck';
const String courseID = '2023-08-10_10:12:24';
const String title = 'A title';

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    StorageCrud.init(storageInstance: MockFirebaseStorage());

    final Reference textRef = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/$courseID/text.txt');
    String text = await rootBundle.loadString('assets/text.txt');
    await textRef.putData(Uint8List.fromList(utf8.encode(text)));

    final Reference courseRefPic1 = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/$courseID/picture1.jpg');
    final ByteData coursePic1 =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    await courseRefPic1.putData(coursePic1.buffer.asUint8List());
    final Reference courseRefPic2 = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/$courseID/picture2.jpg');
    final ByteData coursePic2 =
        await rootBundle.load("assets/pics/background.jpg");
    await courseRefPic2.putData(coursePic2.buffer.asUint8List());

    final ref = StorageCrud.getStorage()
        .ref()
        .child('Mentors/$mentor/courses/$courseID/video1.mp4');
    final videoAsset = await rootBundle.load('assets/vids/video1.mp4');
    await ref.putData(videoAsset.buffer.asUint8List());
  });

  group('Course page screen test', () {
    testWidgets('Course page renders correctly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: CoursesPage(
            mentor: mentor,
            title: title,
            courseID: courseID,
          ),
        ),
      );
      await tester.pump();

      //appBar
      expect(find.text('Course Page'), findsOneWidget);

      //text
      expect(find.text(title), findsOneWidget);

      //images
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'Images',
              skipOffstage: false),
          findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is MemoryImage,
              skipOffstage: false),
          findsNWidgets(2));

      //video
      expect(
          find.byType(VideoPlayerWidget, skipOffstage: false), findsOneWidget);
      expect(find.byType(VideoProgressIndicator, skipOffstage: false),
          findsOneWidget);
      expect(
          find.byType(ElevatedButton, skipOffstage: false), findsNWidgets(4));
    });

    testWidgets('Course page behavior', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: CoursesPage(
            mentor: mentor,
            title: title,
            courseID: courseID,
          ),
        ),
      );
      await tester.pump();

      //pause
      await tester
          .tap(find.byIcon(Icons.pause_circle_outline, skipOffstage: false));

      //play
      await tester
          .tap(find.byIcon(Icons.play_circle_outline, skipOffstage: false));

      //fast forward
      await tester
          .tap(find.byIcon(Icons.fast_forward_outlined, skipOffstage: false));

      //fast rewind
      await tester
          .tap(find.byIcon(Icons.fast_rewind_outlined, skipOffstage: false));
    });
  });
}
