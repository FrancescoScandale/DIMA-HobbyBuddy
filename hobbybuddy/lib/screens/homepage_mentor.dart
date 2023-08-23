/*
  Separators for the upcoming classes in the firebase firestore db
  Fields for the same upcoming class are separated by ;;
*/

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

class MentorPage extends StatefulWidget {
  const MentorPage({Key? key, required this.mentor}) : super(key: key);

  final String mentor;

  @override
  State<MentorPage> createState() => _MentorPageState(mentor);
}

class _MentorPageState extends State<MentorPage> {
  late String _mentor;
  late String _hobby;
  final double _backgroundPadding = 250;
  late Image propic;
  late Image background;
  List<String> _upcomingClasses = [];
  bool completed = false;
  bool downloadMentorPics = false;
  bool downloadInfo = false;
  bool downloadClasses = false;
  String stringa = 'Colors.yellow';

  bool favourite = false;
  Icon mentorNotFavourite = const Icon(
    Icons.favorite_border,
    color: Colors.red,
    size: AppLayout.kIconSize,
  );
  Icon mentorFavourite = const Icon(
    Icons.favorite,
    color: Colors.red,
    size: AppLayout.kIconSize,
  );

  _MentorPageState(String mentor) {
    _mentor = mentor;
  }

  void checkCompletions() {
    if (downloadMentorPics && downloadInfo && downloadClasses) {
      completed = true;
      setState(() {});
    }
  }

  void getInfo() async {
    _hobby = await FirebaseCrud.getHobby(_mentor);

    downloadInfo = true;
    checkCompletions();
  }

  void getMentorPics() async {
    Uint8List? propicData = await FirebaseStorage.instance.ref().child('Mentors/$_mentor/propic.jpg').getData();
    Uint8List? backgroundData = await FirebaseStorage.instance.ref().child('Mentors/$_mentor/background.jpg').getData();

    propic = Image.memory(propicData!);
    background = Image.memory(backgroundData!);

    downloadMentorPics = true;
    checkCompletions();
  }

  void getUpcomingClasses() async {
    _upcomingClasses = await FirebaseCrud.getUpcomingClasses(_mentor);

    downloadClasses = true;
    checkCompletions();
  }

  ///toggles the bool in _mentors<Mentor,Like> to change the displayed icon, updates db and cache
  void toggleLikeMentor() async {
    String username = Preferences.getUsername()!;

    favourite = !favourite;

    if (favourite) {
      //add the new favourite mentor in db
      await FirebaseCrud.updateFavouriteMentors(username, _mentor, 'add');
    } else {
      //remove the favourite mentor from db
      await FirebaseCrud.updateFavouriteMentors(username, _mentor, 'remove');
    }

    //update cache
    await Preferences.setMentors(username);

    setState(() {});
  }

  ///4294961979=yellow, 4288585374=grey, 4294945600=orangeAccent
  Color convertColor(int index) {
    Color result;
    result = Color(int.parse(_upcomingClasses[index].split(';;')[0]));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!completed) {
      favourite = Preferences.getMentors()!.contains(_mentor);
      getMentorPics();
      getInfo();
      getUpcomingClasses();
    }
    return Scaffold(
      appBar: const MyAppBar(
        title: "Mentor Page",
      ),
      body: ListView(
        children: [
          Stack(
            //IMAGES
            children: [
              SizedBox(
                  height: _backgroundPadding,
                  width: MediaQuery.sizeOf(context).width,
                  child: downloadMentorPics
                      ? Image(
                          image: background.image,
                          alignment: Alignment.center,
                          fit: BoxFit.fitHeight,
                        )
                      : Container()),
              Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      2 * AppLayout.kModalHorizontalPadding, 2 * _backgroundPadding / 3, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppLayout.kProfilePicRadiusLarge),
                    child: downloadMentorPics
                        ? Image(
                            image: propic.image,
                            width: AppLayout.kProfilePicRadiusLarge,
                            height: AppLayout.kProfilePicRadiusLarge,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                  ))
            ],
          ),
          Row(
            //INFO
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      AppLayout.kModalHorizontalPadding, AppLayout.kHeightSmall, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        downloadInfo ? _mentor : '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        downloadInfo ? _hobby : '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              MyIconButton(
                margin: const EdgeInsets.only(right: AppLayout.kModalHorizontalPadding),
                onTap: toggleLikeMentor,
                icon: favourite ? mentorFavourite : mentorNotFavourite,
              ),
            ],
          ),
          Container(
            height: AppLayout.kHeightSmall,
          ),
          Container(
            alignment: AlignmentDirectional.topStart,
            padding: const EdgeInsetsDirectional.fromSTEB(AppLayout.kModalHorizontalPadding, 0, 0, 0),
            child: const Text(
              "Upcoming Classes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ContainerShadow(
              margin: EdgeInsetsDirectional.fromSTEB(AppLayout.kHorizontalPadding, 0, AppLayout.kHorizontalPadding, 0),
              //HOBBIES
              //color: ui.Color(0xffffcc80), //TODO?
              child: ListView.builder(
                itemCount: _upcomingClasses.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: downloadInfo
                        ? Image.asset(
                            'assets/hobbies/$_hobby.png',
                            height: AppLayout.kHobbyDimension,
                            fit: BoxFit.cover,
                            color: convertColor(index),
                          )
                        : Container(
                            width: 10,
                            height: 10,
                          ),
                    title: Text(_upcomingClasses[index].split(';;')[1]),
                    trailing: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(_upcomingClasses[index].split(';;')[2]),
                        Text(_upcomingClasses[index].split(';;')[3])
                      ],
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}