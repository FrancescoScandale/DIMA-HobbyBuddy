import 'package:flutter/material.dart';
import 'package:hobbybuddy/screens/my_friends_list.dart';
import 'package:hobbybuddy/screens/search_friend_list.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';

String logo = 'assets/logo.png';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  Future<List<String>> receivedRequestsFuture =
      FirestoreCrud.getReceivedRequest(Preferences.getUsername()!);
  bool _isShrink = false;
  bool _showRedCircle = false;

  @override
  void initState() {
    _tabController = TabController(
        length: 2, vsync: this); // Assuming 2 tabs (My Friends and Explore)
    _scrollController.addListener(() {
      setState(() {
        _isShrink = _scrollController.hasClients &&
            _scrollController.offset > 0; // Adjust this value as needed
      });
    });
    receivedRequestsFuture.then((receivedRequests) {
      _updateRedCircleVisibility(receivedRequests.length);
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateRedCircleVisibility(int newRequestCount) {
    setState(() {
      _showRedCircle = newRequestCount > 0;
    });
  }

  Future<List<String>> req() async {
    List<String> receivedRequests = await receivedRequestsFuture;
    return receivedRequests;
  }

  Future<int> count() async {
    int requestCount;
    List<String> receivedRequests = await req();
    if (receivedRequests == []) {
      requestCount = 0;
    } else {
      requestCount = receivedRequests.length;
    }
    return requestCount;
  }

  static _showRequestsDialog(
    BuildContext context,
    List<String>? receivedRequests,
    int requestCount,
    _MyFriendsScreenState state,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Friendship Requests'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                // Adjust width as needed
                child: SingleChildScrollView(
                  child: Column(
                    children: receivedRequests?.map((request) {
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppLayout.kProfilePicRadiusSmall),
                                child: Image.asset(
                                  'assets/pics/propic.jpg',
                                  width: AppLayout.kProfilePicRadiusSmall,
                                  height: AppLayout.kProfilePicRadiusSmall,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                request,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              ButtonBar(
                                buttonMinWidth: 20,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirestoreCrud.removeSentRequest(
                                          request, Preferences.getUsername()!);
                                      await FirestoreCrud.removeReceivedRequest(
                                          Preferences.getUsername()!, request);
                                      await FirestoreCrud.addFriend(
                                          Preferences.getUsername()!, request);
                                      await FirestoreCrud.addFriend(
                                          request, Preferences.getUsername()!);
                                      setState(() {
                                        receivedRequests.remove(request);
                                      });
                                      state._updateRedCircleVisibility(
                                          receivedRequests.length);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirestoreCrud.removeSentRequest(
                                          request, Preferences.getUsername()!);
                                      await FirestoreCrud.removeReceivedRequest(
                                          Preferences.getUsername()!, request);
                                      setState(() {
                                        receivedRequests.remove(request);
                                      });
                                      state._updateRedCircleVisibility(
                                          receivedRequests.length);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList() ??
                        [],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: receivedRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // The future is still loading
            return Container();
          } else if (snapshot.hasError) {
            // An error occurred while fetching the data
            return Text('Error: ${snapshot.error}');
          } else {
            // Data is available and not empty
            List<String> receivedRequests = snapshot.data!;
            int requestCount = receivedRequests.length;

            return Scaffold(
              appBar: MyAppBar(
                title: "Friends Explorer",
                shape: (_isShrink)
                    ? const Border()
                    : Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                upRightActions: [
                  Stack(
                    children: [
                      if (requestCount >= 0)
                        Container(
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              0, 5, 40, 5), //const EdgeInsets.only(right: 40),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              await _showRequestsDialog(
                                context,
                                receivedRequests,
                                requestCount,
                                this, // Pass the instance of _MyFriendsScreenState
                              );
                            },
                            child: Ink(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffffcc80),
                              ),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    size: 20,
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_showRedCircle)
                        Container(
                          margin: const EdgeInsets.only(
                              bottom: 31, left: 22), // Adjust these values
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  )
                ],
              ),
              body: SafeArea(
                child: ResponsiveWrapper(
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          sliver: SliverPadding(
                            padding: const EdgeInsets.only(top: 0),
                            sliver: SliverAppBar(
                              scrolledUnderElevation: 0,
                              elevation: 1,
                              pinned: true,
                              expandedHeight: 0, // Adjust this value as needed
                              automaticallyImplyLeading: false,
                              centerTitle: true,
                              backgroundColor: _isShrink
                                  ? Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor
                                  : Theme.of(context).scaffoldBackgroundColor,
                              bottom: PreferredSize(
                                preferredSize: const Size.fromHeight(0),
                                child: TabBar(
                                  tabs: ["My friends", "Explore"]
                                      .map((e) => Tab(text: e))
                                      .toList(),
                                  controller: _tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              MyFriendsList(),
                              SearchFriendsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
