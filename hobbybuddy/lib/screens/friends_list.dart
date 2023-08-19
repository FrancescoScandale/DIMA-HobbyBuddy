import 'package:flutter/material.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/bar_switcher.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';

String logo = 'assets/logo.png';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  Future<List<String>> receivedRequestsFuture =
      FirebaseCrud.getReceivedRequest(Preferences.getUsername()!);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: receivedRequestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TabbarSwitcher(
            labels: const ["My friends", "Explore"],
            stickyHeight: 0,
            appBarTitle: "Friends Explorer",
            alwaysShowTitle: true,
            upRightActions: [MyAppBar.acceptRequests(context, snapshot.data)],
            tabbars: const [
              MyFriendsList(),
              SearchFriendsList(),
            ],
          );
        } else {
          return Container(); // Or any loading indicator
        }
      },
    );
  }
}
