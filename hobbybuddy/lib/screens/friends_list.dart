import 'package:flutter/material.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/bar_switcher.dart';

String logo = 'assets/logo.png';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return TabbarSwitcher(
      labels: const ["My friends", "Explore"],
      stickyHeight: 0,
      appBarTitle: "Friends Explorer",
      alwaysShowTitle: true,
      upRightActions: [MyAppBar.acceptRequests(context)],
      tabbars: const [
        MyFriendsList(),
        SearchFriendsList(),
      ],
    );
  }
}
