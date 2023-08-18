import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';

import 'package:hobbybuddy/widgets/button_icon.dart';

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
      body: Column(
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
        ],
      ),
    );
  }
}
