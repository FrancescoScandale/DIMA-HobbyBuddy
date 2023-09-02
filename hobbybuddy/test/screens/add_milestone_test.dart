import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/screens/add_milestone.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/mockito.dart';

final firestore = FakeFirebaseFirestore();
final picker = ImagePicker();
const String username = 'francesco';
const String caption = 'Milestone caption!';

class MockImagePicker extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {
  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final ByteData data =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File pickedFile = await File(
      '${tempDir.path}/pic.jpg',
    ).writeAsBytes(bytes);

    return XFile(pickedFile.path);
  }

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final ByteData data =
        await rootBundle.load("assets/pics/lowqualitybackground.jpg");
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = await getTemporaryDirectory();
    final File pickedFile = await File(
      '${tempDir.path}/pic.jpg',
    ).writeAsBytes(bytes);

    return PickedFile(pickedFile.path);
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile("assets/pics/lowqualitybackground.jpg");
  }
}

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    StorageCrud.init(storageInstance: MockFirebaseStorage());
    ImagePickerPlatform.instance = MockImagePicker();
  });

  group('Add milestone screen test', () {
    testWidgets('Add milestone\'s page renders correctly', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMilestone(
            user: username,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //appBar
      expect(find.text('Add New Milestone'), findsOneWidget);

      //images (hobbies and others)
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));

      expect(
          find.byWidgetPredicate((widget) =>
              widget is MyButton && widget.text == 'Upload Milestone'),
          findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is ElevatedButton && widget.child is Icon),
          findsOneWidget);
    });

    testWidgets('Add milestone\'s page behavior: insert nothing',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMilestone(
            user: username,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //insert nothing
      await tester.tap(
        find.text('Upload Milestone'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Need to insert a caption...'), findsOneWidget);
    });

    testWidgets('Add milestone\'s page behavior: insert caption',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMilestone(
            user: username,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //insert only text
      await tester.enterText(find.byType(TextFormField), caption);
      await tester.pump();
      expect(find.text(caption), findsOneWidget);
      await tester.tap(
        find.text('Upload Milestone'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Need to upload an image...'), findsOneWidget);
    });

    testWidgets('Add milestone\'s page behavior: insert image', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMilestone(
            user: username,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //insert image
      await tester.tap(find.descendant(
          of: find.byType(Container), matching: find.byType(ElevatedButton)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Upload Milestone'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Need to insert a caption...'), findsOneWidget);
    });

    testWidgets('Add milestone\'s page behavior: insert caption and image',
        (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMilestone(
            user: username,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //insert text and image
      await tester.enterText(find.byType(TextFormField), caption);
      await tester.pump();
      await tester.tap(find.descendant(
          of: find.byType(Container), matching: find.byType(ElevatedButton)));
      await tester.pumpAndSettle();

      //tap upload
      await tester.tap(
        find.text('Upload Milestone'),
      );
      await tester.pump();
      expect(find.text('Uploading...'), findsOneWidget);
    });
  });
}
