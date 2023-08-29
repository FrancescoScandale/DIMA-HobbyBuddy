import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/friends_list.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';

final firestore = FakeFirebaseFirestore();

// Create a mock class for FirebaseCrud

void main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Set up fake Firestore instance
    FirestoreCrud.init(firebaseInstance: firestore);
    SharedPreferences.setMockInitialValues({
      "username": "friend0",
    });
    await Preferences.init();
    FirestoreCrud.init(firebaseInstance: firestore);
    await firestore.collection("users").add({
      "username": "friend0",
      "receivedReq": "friend1,friend2", // example received requests
      "sentReq": "", // example sent requests
      "friends": "friend5,friend4", // example friends
    });
    await firestore.collection("users").add({
      "username": "friend1",
      "receivedReq": "",
      "sentReq": "friend0", // example sent requests
      "friends": "friend5",
    });
    await firestore.collection("users").add({
      "username": "friend2",
      "receivedReq": "",
      "sentReq": "friend0", // example sent requests
      "friends": "friend6",
    });
    await firestore.collection("users").add({
      "username": "friend3",
      "receivedReq": "",
      "sentReq": "", // example sent requests
      "friends": "",
    });
    await firestore.collection("users").add({
      "username": "friend4",
      "receivedReq": "",
      "sentReq": "", // example sent requests
      "friends": "friend0",
    });
    await firestore.collection("users").add({
      "username": "friend5",
      "receivedReq": "",
      "sentReq": "", // example sent requests
      "friends": "friend0,friend1",
    });
    await firestore.collection("users").add({
      "username": "friend6",
      "receivedReq": "",
      "sentReq": "", // example sent requests
      "friends": "friend0,friend2",
    });
  });

  testWidgets(
      'MyFriendsScreen renders correctly and user can interact with friendship request dialog',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title is visible
    expect(find.text('Friends Explorer'), findsOneWidget);

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(MyFriendsList), findsOneWidget);
    expect(find.text('friend5'), findsOneWidget);
    expect(find.text('friend4'), findsOneWidget);
    //change tabBar view
    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    //check if found
    expect(find.byType(SearchFriendsList), findsOneWidget);
    expect(find.text('friend1'), findsOneWidget);
    expect(find.text('friend2'), findsOneWidget);
    expect(find.text('friend6'), findsOneWidget);
    //change tabBar view
    await tester.tap(find.text("My friends"));
    await tester.pumpAndSettle();
    //check if found
    expect(find.byType(MyFriendsList), findsOneWidget);

    //tap on received requests icon
    await tester.tap(find.byIcon(Icons.person_add_alt_1));
    await tester.pumpAndSettle();
    // Verify that the dialog appears
    final dialog = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog, findsOneWidget);
    expect(find.text('friend1'), findsOneWidget);
    await tester.tap(find.text('Accept').first);
    expect(find.text('friend2'), findsOneWidget);
    await tester.tap(find.text("Decline").last);

    // Verify that the dialog closes
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify that the title is still visible
    expect(find.text('Friends Explorer'), findsOneWidget);
    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    //check if found
    expect(find.byType(SearchFriendsList), findsOneWidget);
    expect(find.text('friend1'), findsNothing);
    expect(find.text('friend2'), findsOneWidget);
    //change tabBar view
    await tester.tap(find.text("My friends"));
    await tester.pumpAndSettle();
    expect(find.text('friend1'), findsOneWidget);
    expect(find.text('friend2'), findsNothing);
    expect(find.text('friend5'), findsOneWidget);
    expect(find.text('friend4'), findsOneWidget);
  });

  testWidgets('MyFriendsScreen renders correctly and user can delete friend',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Friends Explorer'), findsOneWidget);

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();

    expect(find.byType(SearchFriendsList), findsOneWidget);
    expect(find.text('friend5'), findsNothing);
    await tester.tap(find.text("My friends"));
    await tester.pumpAndSettle();

    expect(find.byType(MyFriendsList), findsOneWidget);
    expect(find.text('friend5'), findsOneWidget);
    expect(find.text('friend4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_remove).first);
    await tester.pumpAndSettle();
    final dialog = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog, findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('friend5'), findsNothing);

    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    expect(find.byType(SearchFriendsList), findsOneWidget);

    expect(find.text('friend5'), findsOneWidget);
  });

  testWidgets(
      'MyFriendsScreen renders correctly and user can send friendship request',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    expect(find.text('friend2'), findsOneWidget);

    expect(find.byIcon(Icons.add_circle), findsNWidgets(4));
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pumpAndSettle();

    final dialog = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog, findsOneWidget);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_circle), findsNWidgets(3));
    expect(find.byIcon(Icons.pending), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pending).first);
    await tester.pumpAndSettle();

    final dialog2 = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog2, findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_circle), findsNWidgets(4));
    expect(find.byIcon(Icons.pending), findsNothing);
  });
}
