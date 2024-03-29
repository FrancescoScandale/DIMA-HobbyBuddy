import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'dart:ui' as ui;
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';

class HomePScreen extends StatefulWidget {
  const HomePScreen({super.key});

  @override
  State<HomePScreen> createState() => _HomePScreenState();
}

class _HomePScreenState extends State<HomePScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool alphabeticAsc = true;
  List<String> _hobbies = [];
  List<bool> checkFavouriteHobby = [];
  List<String> _filteredHobbies = [];

  @override
  void initState() {
    super.initState();
    retriveHobbies();

    _searchController.addListener(_performSearch);
  }

  double _calculateAspectRatio() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      if (width > 600) {
        return 3.7 * width / height;
      } else {
        return 2.6 * width / height;
      }
    } else {
      if (height > 600) {
        return width / (0.65 * height);
      } else {
        return width / (1.3 * height);
      }
    }
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

/// Sets "checkFavouriteHobby" for each hobby based on the favourite hobbies
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
      List<String> hobbies = await FirestoreCrud.getHobbies();
      setState(() {
        _hobbies = hobbies;
        _filteredHobbies = _hobbies;
        checkFavouriteHobby =
            List.generate(_filteredHobbies.length, (_) => false);
      });
    }
    setFavouriteStatus();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _searchController.dispose();
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
            expandedHeight: 166,
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
                                  ? _filteredHobbies.sort((a, b) => a
                                      .toLowerCase()
                                      .compareTo(b.toLowerCase()))
                                  : _filteredHobbies.sort((a, b) => b
                                      .toLowerCase()
                                      .compareTo(a.toLowerCase()));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width < 600 ||
                      (MediaQuery.of(context).size.width >= 600 &&
                          MediaQuery.of(context).orientation ==
                              Orientation.portrait))
                  ? 2
                  : 3, // Two or three hobbies per row
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: _calculateAspectRatio(),
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    Widget newScreen =
                        HomePageHobby(hobby: _filteredHobbies[index]);
                    await Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        )).then((_) {
                      setState(() {
                        setFavouriteStatus();
                      });
                    });
                  },
                  child: ContainerShadow(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const ui.Color(0xffffcc80),
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
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0),
                              child: Text(_filteredHobbies[index],
                                  style: const TextStyle(fontSize: 17)),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  right: 8.0),
                              child: Icon(Icons.navigate_next),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _filteredHobbies.length,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 60.0),
          ),
        ],
      ),
    );
  }
}
