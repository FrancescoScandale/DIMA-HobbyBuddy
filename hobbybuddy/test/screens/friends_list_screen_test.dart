import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hobbybuddy/screens/friends_list.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';

final firestore = FakeFirebaseFirestore();

// Create a mock class for FirebaseCrud
class MockFirebaseCrud extends Mock implements FirebaseCrud {
  static Future<List<String>> getReceivedRequest(String username) async {
    print('getReceivedRequest method called with username: $username');
    try {
      final userDoc = await firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String receivedRequestString =
            userDoc.docs[0].get("receivedReq") as String;
        List<String> receivedRequests = receivedRequestString.isNotEmpty
            ? receivedRequestString.split(',')
            : [];
        return receivedRequests;
      }
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  static Future<void> removeSentRequest(
      String user, String friendToRemove) async {
    try {
      final userDoc = await firestore
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("sentReq");
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];
        friendList.remove(friendToRemove);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'sentReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> removeReceivedRequest(
      String user, String friendToRemove) async {
    try {
      final userDoc = await firestore
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("receivedReq");
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];

        friendList.remove(friendToRemove);

        String updatedFriendString = friendList.join(',');

        await userDoc.docs[0].reference
            .update({'receivedReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> addFriend(String user, String friendToAdd) async {
    try {
      final userDoc = await firestore
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("friends") as String;
        List<String> friendList = tmp.split(',');
        friendList.add(friendToAdd);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'friends': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() {
  CustomBindings();

  setUp(() async {
    // Set up fake Firestore instance
    SharedPreferences.setMockInitialValues({
      "username": "mockUser",
    });
    await firestore.collection("users").add({
      "username": "mockUser",
      "receivedReq": "friend1,friend2", // example received requests
      "sentReq": "friend3,friend4", // example sent requests
      "friends": "friend5,friend6", // example friends
    });
  });

  testWidgets('MyFriendsScreen renders correctly with an empty dialog',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await Preferences.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<FirebaseCrud>(
            create: (context) => MockFirebaseCrud(),
          ),
        ],
        child: const MaterialApp(
          home: MyFriendsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title is visible
    expect(find.text('Friends Explorer'), findsOneWidget);

    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(MyFriendsList), findsOneWidget);
    //change tabBar view
    await tester.tap(find.text("Explore"));
    await tester.pumpAndSettle();
    //check if found
    expect(find.byType(SearchFriendsList), findsOneWidget);
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

    // Verify that the dialog closes
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify that the title is still visible
    expect(find.text('Friends Explorer'), findsOneWidget);
  });
}
