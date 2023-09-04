import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

class SearchFriendsList extends StatefulWidget {
  final VoidCallback? onRefreshMainPage;
  const SearchFriendsList({Key? key, this.onRefreshMainPage}) : super(key: key);

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
    retriveSentRequests();
    _searchController.addListener(_performSearch);
  }

  @override
  void didUpdateWidget(SearchFriendsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    retriveSentRequests(); // Update pending requests when widget updates
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
      List<String> friends = await FirestoreCrud.getAllOtherUsernames(username);
      setState(() {
        _friends = friends;
        _filteredFriends = _friends;
      });
    }
  }

  Future<void> retriveSentRequests() async {
    String username = Preferences.getUsername()!;
    if (_pendingRequests.isEmpty) {
      List<String> sentRequests = await FirestoreCrud.getSentRequest(username);
      setState(() {
        _pendingRequests = sentRequests;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        primary: true,
        clipBehavior: Clip.none,
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
            RefreshIndicator(
              onRefresh: () async {
                widget.onRefreshMainPage!();
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredFriends.length,
                itemBuilder: (context, index) {
                  final friendName = _filteredFriends[index];
                  final bool isPending = _pendingRequests.contains(friendName);
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
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
                                      margin: const EdgeInsets.only(right: 20),
                                      onTap: () {
                                        if (!isPending) {
                                          _showAddFriendDialog(friendName);
                                        } else {
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFriendDialog(String friendName) async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new Buddy!'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                const TextSpan(
                  text: 'Do you want to send ',
                ),
                TextSpan(
                  text: friendName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ' a friendship request?',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Send',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
        _pendingRequests.add(friendName);
      });

      await FirestoreCrud.addSentRequest(
          Preferences.getUsername()!, friendName);
      await FirestoreCrud.addReceivedRequest(
          friendName, Preferences.getUsername()!);
    }
  }

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
                const TextSpan(
                  text: 'Do you want to delete the friendship request to ',
                ),
                TextSpan(
                  text: friendName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '?',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
        _pendingRequests.remove(friendName);
      });

      await FirestoreCrud.removeSentRequest(
          Preferences.getUsername()!, friendName);
      await FirestoreCrud.removeReceivedRequest(
          friendName, Preferences.getUsername()!);
    }
  }
}
