import 'package:flutter/material.dart';

import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

class MyFriendsList extends StatefulWidget {
  const MyFriendsList({super.key});

  @override
  State<MyFriendsList> createState() => _MyFriendsListState();
}

class _MyFriendsListState extends State<MyFriendsList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool alphabeticAsc = true;
  List<String> _friends = [];
  List<String> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    retriveFriends();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends
            .where((element) => element
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> retriveFriends() async {
    String username = Preferences.getUsername()!;
    if (_friends.isEmpty) {
      List<String> friends = await FirebaseCrud.getFriends(username);
      setState(() {
        _friends = friends;
        _filteredFriends = _friends;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search for a friend',
                  prefixIcon: const Icon(Icons.search_sharp),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => _performSearch(),
              ),
            ),
            Padding(
              //mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 3, 20, 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyIconButton(
                    icon: const Icon(Icons.sort_by_alpha_outlined),
                    onTap: () {
                      setState(() {
                        alphabeticAsc = !alphabeticAsc;
                        alphabeticAsc
                            ? _filteredFriends.sort((a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()))
                            : _filteredFriends.sort((a, b) =>
                                b.toLowerCase().compareTo(a.toLowerCase()));
                      });
                    },
                  ),
                ],
              ),
            ),
            Scrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                controller: PrimaryScrollController.of(context),
                itemCount: _filteredFriends.length,
                // Number of rectangles you want to display
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      Widget newScreen =
                          UserPage(user: _filteredFriends[index]);
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20, 3, 0, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppLayout.kProfilePicRadiusLarge),
                                  child: Image.asset(
                                    'assets/pics/propic.jpg',
                                    width: AppLayout.kProfilePicRadius,
                                    height: AppLayout.kProfilePicRadius,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                // Wrap with Expanded widget
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // Align text and icon to the extremes
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        _filteredFriends[index],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    MyIconButton(
                                      icon: Icon(Icons.person_remove,
                                          color: Theme.of(context)
                                              .primaryColorLight),
                                      margin: const EdgeInsets.only(right: 20),
                                      onTap: () {
                                        _showRemoveFriendDialog(
                                            _filteredFriends[index]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the confirmation dialog
  Future<void> _showRemoveFriendDialog(String friendName) async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Friend'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                const TextSpan(text: 'Do you want to remove '),
                TextSpan(
                  text: friendName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ' from your friends?',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmed action
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Canceled action
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmAction == true) {
      setState(() {
        _friends.remove(friendName);
        _filteredFriends.remove(friendName);
      });

      await FirebaseCrud.removeFriend(Preferences.getUsername()!, friendName);
      await FirebaseCrud.removeFriend(friendName, Preferences.getUsername()!);
    }
  }
}
