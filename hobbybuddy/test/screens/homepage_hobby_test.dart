import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firestore = FakeFirebaseFirestore();

void main() async {
  setUp(() async {
    FirestoreCrud.init(firebaseInstance: firestore);
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues({
      'isDark': true,
      'username': 'francesco',
      'hobbies': ['Skateboard', 'Chess'],
      'mentors': ['Emma Watson', 'Ben Affleck', 'Lewis Hamilton'],
    });
    await Preferences.init();

    await firestore.collection("users").add({
      'username': 'francesco',
      'hobbies': ['Skateboard', 'Chess'],
      'mentors': ['Emma Watson', 'Ben Affleck', 'Lewis Hamilton'],
    });

    await firestore.collection('mentors').add({
      'name': 'Ben',
      'surname': 'Affleck',
      'hobby': 'Skateboard',
    });

    await firestore.collection('mentors').add({
      'name': 'Lewis',
      'surname': 'Hamilton',
      'hobby': 'Skateboard',
    });

    await firestore.collection('mentors').add({
      'name': 'Emma',
      'surname': 'Watson',
      'hobby': 'Chess',
    });

    await firestore.collection('mentors').add({
      'name': 'John',
      'surname': 'Travolta',
      'hobby': 'Skateboard',
    });
  });

  group('Hobby homepage screen test', () {
    testWidgets('Hobby\'s homepage renders correctly', (tester) async {
      const String hobby = 'Skateboard';
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageHobby(
            hobby: hobby,
          ),
        ),
      );
      await tester.pumpAndSettle();

      //appBar
      expect(
        find.text('Home Page Hobby'),
        findsOneWidget,
      );

      //icon and text
      expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                widget.image.toString().contains('Skateboard.png'),
          ),
          findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text && widget.toString().contains('Skateboard')),
        findsOneWidget,
      );

      //mentors
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text && widget.toString().contains('Mentors')),
        findsOneWidget,
      );
      expect(find.byType(ContainerShadow), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));

      //'favorite' icons
      expect(find.byIcon(Icons.favorite), findsNWidgets(3));
      expect(find.byIcon(Icons.favorite_outline), findsNWidgets(1));
    });

    testWidgets('Hobby\'s homepage behavior', (tester) async {
      const String hobby = 'Skateboard';
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageHobby(
            hobby: hobby,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_outline).last);
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.favorite),
        findsNWidgets(4),
      );
      assert(Preferences.getMentors()!.length == 4);

      await tester.tap(find.byKey(const Key('toggleHobby')));
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.favorite),
        findsNWidgets(3),
      );
      assert(!Preferences.getHobbies()!.contains('Skateboard'));

      await tester.tap(find.byIcon(Icons.favorite).last);
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.favorite),
        findsNWidgets(2),
      );
      assert(Preferences.getMentors()!.length == 3);

      await tester.tap(find.byKey(const Key('toggleHobby')));
      await tester.pumpAndSettle();
      expect(
        find.byIcon(Icons.favorite),
        findsNWidgets(3),
      );
      assert(Preferences.getHobbies()!.contains('Skateboard'));
    });
  });
}
