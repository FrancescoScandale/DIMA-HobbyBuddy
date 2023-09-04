import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobbybuddy/screens/friends_list.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';

final firestore = FakeFirebaseFirestore();

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Set up fake Firestore instance
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

  testWidgets('My Friends refreshes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('friend5'), findsOneWidget);
    expect(find.text('friend4'), findsOneWidget);
    await tester.fling(find.text('friend5'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    expect(
        tester.getSemantics(find.byType(RefreshProgressIndicator)),
        matchesSemantics(
          label: 'Refresh',
        ));

    await tester
        .pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator settle animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator hide animation
    expect(find.text('friend5'), findsOneWidget);
    expect(find.text('friend4'), findsOneWidget);
    await tester.tap(find.text("friend5"));
    handle.dispose();
  });

  testWidgets('Explore refreshes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    await tester.fling(find.text('friend3'), const Offset(0.0, 300.0), 1000.0);
    await tester.pump();
    expect(
        tester.getSemantics(find.byType(RefreshProgressIndicator)),
        matchesSemantics(
          label: 'Refresh',
        ));

    await tester
        .pump(const Duration(seconds: 1)); // finish the scroll animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator settle animation
    await tester.pump(
        const Duration(seconds: 1)); // finish the indicator hide animation
    await tester.tap(find.text("friend3"));
    handle.dispose();
  });

  testWidgets('MyFriendsScreen allows friends and users to be searched',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    await tester.pumpWidget(
      const MaterialApp(
        home: MyFriendsScreen(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text("My friends"));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              widget.image.toString().contains('pics/propic.jpg'),
        ),
        findsNWidgets(2));
    final search = find.byType(TextField);
    expect(search, findsOneWidget);
    await tester.enterText(search, '4');

    await tester.tap(find.byIcon(Icons.search_sharp));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.sort_by_alpha_outlined));
    await tester.pumpAndSettle();

    expect(find.text('friend4'), findsOneWidget);
    expect(find.text('friend5'), findsNothing);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('friend4'), findsOneWidget);
    expect(find.text('friend5'), findsOneWidget);

    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              widget.image.toString().contains('pics/propic.jpg'),
        ),
        findsNWidgets(4));
    final search2 = find.byType(TextField);
    expect(search2, findsOneWidget);
    await tester.enterText(search2, '3');

    await tester.tap(find.byIcon(Icons.search_sharp));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.sort_by_alpha_outlined));
    await tester.pumpAndSettle();
    expect(find.text('friend3'), findsOneWidget);
    expect(find.text('friend6'), findsNothing);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('friend3'), findsOneWidget);
    expect(find.text('friend6'), findsOneWidget);
  });

  testWidgets(
      'MyFriendsScreen renders correctly and user can interact with friendship request dialog to accept or decline a request',
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
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('friend5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_remove).first);
    await tester.pumpAndSettle();
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
      'MyFriendsScreen renders correctly and user can send friendship request and revoke a pending request',
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

    //opens dialog, but doesn't send request
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pumpAndSettle();

    final dialog = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog, findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    //opens dialog and sends request
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pumpAndSettle();

    final dialog2 = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog2, findsOneWidget);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_circle), findsNWidgets(3));
    expect(find.byIcon(Icons.pending), findsOneWidget);

    //opens dialog and closes withdraw request
    await tester.tap(find.byIcon(Icons.pending).first);
    await tester.pumpAndSettle();

    final dialog3 = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog3, findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    //opens dialog and confirm withdraw request
    await tester.tap(find.byIcon(Icons.pending).first);
    await tester.pumpAndSettle();

    final dialog4 = find.byWidgetPredicate((widget) => widget is AlertDialog);
    expect(dialog4, findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_circle), findsNWidgets(4));
    expect(find.byIcon(Icons.pending), findsNothing);
  });
}
