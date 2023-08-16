import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';

import 'package:hobbybuddy/services/firebase_queries.dart';

import '../widgets/app_bar.dart';

class HomePageHobby extends StatefulWidget {
  const HomePageHobby({Key? key, required this.hobby}) : super(key: key);

  final String hobby;

  @override
  State<HomePageHobby> createState() => _HomePageHobbyState(hobby);
}

class _HomePageHobbyState extends State<HomePageHobby> {
  late String _hobby = widget.hobby; //TODO: constructor has to be called in order to set this parameter
  Map<String, bool> _mentors = {};

  //icons for the hobby
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

  //icons for the mentors
  Icon mentorNotFavourite = const Icon(
    Icons.favorite_border,
    color: Colors.red,
    size: AppLayout.kIconSize / 2,
  );
  Icon mentorFavourite = const Icon(
    Icons.favorite,
    color: Colors.red,
    size: AppLayout.kIconSize / 2,
  );

  _HomePageHobbyState(String hobby) {
    _hobby = hobby;
  }

  ///toggles "checkFavouriteHobby" in order to change the icon displayed, updates db and cache
  void toggleFavouriteHobby() async {
    String username = Preferences.getUsername()!;

    checkFavouriteHobby = !checkFavouriteHobby;

    if (checkFavouriteHobby) {
      //add the new favourite hobby in db
      await FirebaseCrud.updateFavouriteHobbies(username, _hobby, 'add');
    } else {
      //remove the favourite hobby from db
      await FirebaseCrud.updateFavouriteHobbies(username, _hobby, 'remove');
    }

    //update cache
    await Preferences.setHobbies(username);

    setState(() {});
  }

  ///toggles the bool in _mentors<Mentor,Like> to change the displayed icon, updates db and cache
  void toggleLikeMentor(String mentor) async {
    String username = Preferences.getUsername()!;

    _mentors[mentor] = !_mentors[mentor]!;

    if (_mentors[mentor]!) {
      //add the new favourite mentor in db
      await FirebaseCrud.updateFavouriteMentors(username, mentor, 'add');
    } else {
      //remove the favourite mentor from db
      await FirebaseCrud.updateFavouriteMentors(username, mentor, 'remove');
    }

    //update cache
    await Preferences.setMentors(username);

    setState(() {});
  }

  //sets "checkFavouriteHobby" based on the favourite hobbies
  void setFavouriteStatus() {
    checkFavouriteHobby = Preferences.getHobbies()!.contains(_hobby);
  }

  void retrieveMentors() async {
    if (_mentors.isEmpty) {
      //TODO: passando da un hobby all'altro, questo potrebbe avere bisogno di essere
      //inizializzato di nuovo... se la schermata è nuova invece dovrebbe essere a posto
      _mentors = await FirebaseCrud.getMentors(_hobby);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    setFavouriteStatus();
    retrieveMentors();
    return Scaffold(
      appBar: const MyAppBar(
        title: "Home Page Hobby",
      ),
      body: ListView(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: 160,
            decoration: const BoxDecoration(
              color: ui.Color(0xffffcc80),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/hobbies/$_hobby.png",
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          SizedBox(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(AppLayout.kModalHorizontalPadding, 0, 0, 0),
                child: Text(
                  _hobby,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 2 * AppLayout.kModalHorizontalPadding, 0),
                child: MyIconButton(
                  onTap: toggleFavouriteHobby,
                  icon: checkFavouriteHobby ? hobbyFavourite : hobbyNotFavourite,
                ),
              ),
            ],
          )),
          Container(
            height: AppLayout.kPaddingFromCreate,
          ),
          Container(
            alignment: AlignmentDirectional.topStart,
            padding: const EdgeInsetsDirectional.fromSTEB(AppLayout.kModalHorizontalPadding, 0, 0, 0),
            child: const Text(
              "Mentors",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ContainerShadow(
              margin: const EdgeInsetsDirectional.fromSTEB(
                  AppLayout.kModalHorizontalPadding, 0, AppLayout.kModalHorizontalPadding, 0),
              child: ListView.builder(
                itemCount: _mentors.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person), //TODO: mettere la propic del mentore
                    title: Text(_mentors.keys.elementAt(index)),
                    trailing: MyIconButton(
                      onTap: () {
                        toggleLikeMentor(_mentors.keys.elementAt(index));
                      },
                      icon: _mentors.values.elementAt(index) ? mentorFavourite : mentorNotFavourite,
                    ),
                    //onTap: loadMentorProfile(), //TODO: load mentor profile on click
                  );
                },
              )),
        ],
      ),
    );
  }
}
