import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

class SearchFriendsList extends StatefulWidget {
  const SearchFriendsList({super.key});

  @override
  State<SearchFriendsList> createState() => _SearchFriendsListState();
}

class _SearchFriendsListState extends State<SearchFriendsList> {
  final TextEditingController _searchController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool alphabeticAsc = true;
  List<String> _friends = [];
  List<String> _filteredFriends = [];
  List<String> _pendingRequests = [];
  @override
  void initState() {
    super.initState();
    retriveUsers();
    _searchController.addListener(_performSearch);
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

  Future<void> retriveUsers() async {
    String username = Preferences.getUsername()!;
    if (_friends.isEmpty) {
      List<String> friends = await FirebaseCrud.getAllOtherUsernames(username);
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
                    icon: Icon(Icons.clear),
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
                  final friendName = _filteredFriends[index];
                  final isPending = _pendingRequests.contains(friendName);
                  return Container(
                    child: GestureDetector(
                      onTap: () async {
                        Widget newScreen = const UserPage();
                        Navigator.push(
                          context,
                          ScreenTransition(
                            builder: (context) => newScreen,
                          ),
                        );
                      },
                      child: Container(
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
                                        icon: Icon(
                                          isPending
                                              ? Icons.pending
                                              : Icons.add_circle,
                                          color: isPending
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .primaryColorLight,
                                        ),
                                        margin: EdgeInsets.only(right: 20),
                                        onTap: () {
                                          if (!isPending) {
                                            _showRemoveFriendDialog(friendName);
                                          }
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

  Future<void> _showRemoveFriendDialog(String friendName) async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new Buddy!'),
          content: Text('Do you want to send $friendName a friend request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmed action
              },
              child: Text('Send'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Canceled action
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmAction == true) {
      setState(() {
        _pendingRequests.add(friendName); // Add friend to pending requests
      });

      await FirebaseCrud.addSentRequest(Preferences.getUsername()!, friendName);
      await FirebaseCrud.addReceivedRequest(
          friendName, Preferences.getUsername()!);
    }
  }
}
