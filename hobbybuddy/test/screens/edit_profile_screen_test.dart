import 'dart:io';
import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final firestore = FakeFirebaseFirestore();
final picker = ImagePicker();

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

  @Deprecated('Use getImageFromSource instead.')
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
    FirestoreCrud.init(firebaseInstance: firestore);
    StorageCrud.init(storageInstance: MockFirebaseStorage());
    ImagePickerPlatform.instance = MockImagePicker();
    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      'username': 'marta',
    });
    await firestore.collection("users").add({
      'username': 'marta',
      'name': 'marta',
      'surname': 'radaelli',
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

  group('EditProfileScreen test', () {
    testWidgets('EditProfileScreen saves new name and surname', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await Preferences.init();
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      final backgroundImage = find.byKey(const Key("backgImage"));
      expect(backgroundImage, findsOneWidget);

      expect(
        find.byType(Image),
        findsNWidgets(2),
      );
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .first);
      await tester.pumpAndSettle();

      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .last);
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close),
          findsNWidgets(2));

      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close)
          .first);
      await tester.pumpAndSettle();

      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close)
          .last);
      await tester.pumpAndSettle();
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      );

      final nameField = find.byKey(const Key("newName"));
      expect(nameField, findsOneWidget);

      final surnameField = find.byKey(const Key("newSurname"));
      expect(surnameField, findsOneWidget);

      expect(find.byIcon(Icons.shortcut_rounded), findsNWidgets(2));

      await tester.enterText(nameField, 'francesco');
      await tester.enterText(surnameField, 'scandale');
      final buttonToTap = find.byKey(const Key('saveB'));

      await tester.tap(buttonToTap);
      await tester.pumpAndSettle();
    });

    testWidgets('EditProfileScreen handles image changes', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      await Preferences.init();
      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      final image = find.byKey(const Key("backgImage"));
      expect(image, findsOneWidget);

      expect(
        find.byType(Image),
        findsNWidgets(2),
      );

      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .first);
      await tester.pumpAndSettle();

      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.photo_camera)
          .last);
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Icon && widget.icon == Icons.close),
          findsNWidgets(2));

      // Find TextFormField widgets
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      );

      final nameField = find.byKey(const Key("newName"));
      expect(nameField, findsOneWidget);

      final surnameField = find.byKey(const Key("newSurname"));
      expect(surnameField, findsOneWidget);

      expect(find.byIcon(Icons.shortcut_rounded), findsNWidgets(2));

      final buttonToTap = find.byKey(const Key('saveB'));

      await tester.tap(buttonToTap);
      await tester.pumpAndSettle();
    });
  });
}
