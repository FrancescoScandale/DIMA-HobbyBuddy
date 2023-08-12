import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'dart:ui' as ui;
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/main.dart';

class HomePScreen extends StatefulWidget {
  const HomePScreen({super.key});

  @override
  State<HomePScreen> createState() => _HomePScreenState();
}

class _HomePScreenState extends State<HomePScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _addressController = TextEditingController();
  final String _hobby = "Skateboard";

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
  bool checkFavouriteHobby = false;

  //sets "checkFavouriteHobby" based on the favourite hobbies
  void setFavouriteStatus() {
    checkFavouriteHobby = !checkFavouriteHobby;
    checkFavouriteHobby = Preferences.getHobbies()!.contains(_hobby);
  }

  void filterSearchResults(String query) {
    setState(() {});
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setFavouriteStatus();
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 40, 0, 0),
                  child: Image.asset(
                    'logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.fitWidth,
                  ),
                ),*/
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 20, 24, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Find your new Passion with Hobby Buddy',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: const AlignmentDirectional(0, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    4, 0, 4, 0),
                                child: TextField(
                                  onChanged: (value) {
                                    filterSearchResults(value);
                                  },
                                  controller: _addressController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    labelText: 'Search a Hobby',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_sharp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /*Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  2, 0, 8, 0),
                              child: ElevatedButton(
                                onPressed: () async {

                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Text(
                                  'Search',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),

            // Add the other part of the page here
            GestureDetector(
              onTap: () async {
                Widget newScreen = const HomePageHobby();
                Navigator.push(
                  context,
                  ScreenTransition(
                    builder: (context) => newScreen,
                  ),
                );
              },
              child: Container(
                height: 400, // Adjust the height as needed
                child: Scrollbar(
                  child: ListView.builder(
                    controller: PrimaryScrollController.of(context),
                    itemCount: 10, // Number of rectangles you want to display
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                        200, // Adjust the image height as needed

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
                                        "assets/hobbies/$_hobby.png",
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('n of likes'),
                                        SizedBox(width: 4),
                                        Icon(
                                          (checkFavouriteHobby
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0), // Add left padding
                                    child: Text(
                                      _hobby,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
