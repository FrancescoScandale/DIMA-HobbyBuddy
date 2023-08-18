import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'dart:ui' as ui;
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';

class HomePScreen extends StatefulWidget {
  const HomePScreen({super.key});

  @override
  State<HomePScreen> createState() => _HomePScreenState();
}

class _HomePScreenState extends State<HomePScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<String> _hobbies = [];
  List<bool> checkFavouriteHobby = [];
  List<String> _filteredHobbies = [];

  @override
  void initState() {
    super.initState();
    retriveHobbies();

    _searchController.addListener(_performSearch);
  }

  Future<void> _performSearch() async {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredHobbies = _hobbies;
        setFavouriteStatus(); // Update the favorite status when clearing the search
      } else {
        _filteredHobbies = _hobbies
            .where((element) => element
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }

      setFavouriteStatus();
    });

    // Update the checkFavouriteHobby list to match the filtered hobbies
    List<bool> updatedFavouriteStatus = _filteredHobbies.map((hobby) {
      int originalIndex = _hobbies.indexOf(hobby);
      if (originalIndex != -1) {
        return checkFavouriteHobby[originalIndex];
      }
      return false;
    }).toList();
    setState(() {
      checkFavouriteHobby = List.from(updatedFavouriteStatus);
    });
  }

  //icons for the number of likes
  Icon hobbyNotFavourite = const Icon(
    Icons.favorite_border,
    color: Colors.red,
    size: AppLayout.kIconSize,
  );
  Icon hobbyFavourite = const Icon(
    Icons.favorite,
    color: Colors.red,
    size: AppLayout.kIconSize,
  );

// Sets "checkFavouriteHobby" for each hobby based on the favourite hobbies
  void setFavouriteStatus() {
    List<String>? favoriteHobbies = Preferences.getHobbies();

    if (favoriteHobbies != null) {
      checkFavouriteHobby =
          _hobbies.map((hobby) => favoriteHobbies.contains(hobby)).toList();
    } else {
      checkFavouriteHobby = List.generate(_hobbies.length, (_) => false);
    }
  }

  Future<void> retriveHobbies() async {
    if (_hobbies.isEmpty) {
      List<String> hobbies = await FirebaseCrud.getHobbies();
      setState(() {
        _hobbies = hobbies;
        _filteredHobbies = _hobbies;
        checkFavouriteHobby =
            List.generate(_filteredHobbies.length, (_) => false);
      });
    }
    setFavouriteStatus(); // Call this after retrieving hobbies
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Hobby Buddy"),
      key: scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            expandedHeight: 133, // Adjust as needed
            flexibleSpace: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 8),
                    child: Text(
                      'Find your new Passion with Hobby Buddy',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search a Hobby',
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
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    Widget newScreen = HomePageHobby(hobby: _filteredHobbies[index]);
                    Navigator.push(
                      context,
                      ScreenTransition(
                        builder: (context) => newScreen,
                      ),
                    );
                  },
                  child: Container(
                    child: ContainerShadow(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: double.infinity,
                                height:
                                    120, // Adjust the image height as needed

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: ui.Color(0xffffcc80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .shadowColor
                                          .withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    "assets/hobbies/${_filteredHobbies[index]}.png",
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (checkFavouriteHobby[index]
                                          ? Icons.favorite
                                          : Icons.favorite_border),
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 8), // Spacing between image and title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0), // Add left padding
                                child: Text(_filteredHobbies[index],
                                    style: TextStyle(fontSize: 17)),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    right: 8.0), // Add right padding
                                child: Icon(Icons.navigate_next),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _filteredHobbies.length,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 40.0),
          ),
        ],
      ),
    );
  }
}
