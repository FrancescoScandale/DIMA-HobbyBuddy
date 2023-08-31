/*
  Legend for the upcoming classes in the firebase firestore db
    Fields for the same upcoming class are separated by ;;
    Tiers of difficulty are 1,2,3 (1 being the hardest -> red)
*/

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/screens/courses.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:tuple/tuple.dart';

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
  Map<String, Tuple2<String, Image>> _courses = {};
  bool downloadMentorPics = false;
  bool downloadInfo = false;
  bool downloadClasses = false;
  bool downloadCourses = false;

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

  @override
  void initState() {
    favourite = Preferences.getMentors()!.contains(_mentor);
    getMentorPics();
    getInfo();
    getUpcomingClasses();
    getCourses();
    super.initState();
  }

  void getInfo() async {
    _hobby = await FirestoreCrud.getHobby(_mentor);
    setState(() {
      downloadInfo = true;
    });
  }

  void getMentorPics() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Mentors/$_mentor/')
        .listAll();

    if (result.items.isNotEmpty) {
      Uint8List? propicData = await StorageCrud.getStorage()
          .ref()
          .child('Mentors/$_mentor/propic.jpg')
          .getData();
      Uint8List? backgroundData = await StorageCrud.getStorage()
          .ref()
          .child('Mentors/$_mentor/background.jpg')
          .getData();
      propic = Image.memory(propicData!);
      background = Image.memory(backgroundData!);
    } else {
      propic = Image.asset('assets/pics/propic.jpg');
      background = Image.asset('assets/pics/background.jpg');
    }

    setState(() {
      downloadMentorPics = true;
    });
  }

  void getUpcomingClasses() async {
    _upcomingClasses = await FirestoreCrud.getUpcomingClasses(_mentor);

    setState(() {
      if (_upcomingClasses.isNotEmpty) {
        downloadClasses = true;
      }
    });
  }

  void getCourses() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Mentors/$_mentor/courses/')
        .listAll();
    if (result.prefixes.isNotEmpty) {
      for (Reference prefs in result.prefixes) {
        String tmp = prefs.fullPath.split('/').last;
        Uint8List? title = await StorageCrud.getStorage()
            .ref()
            .child('Mentors/$_mentor/courses/$tmp/title.txt')
            .getData();
        Uint8List? image = await StorageCrud.getStorage()
            .ref()
            .child('Mentors/$_mentor/courses/$tmp/pic.jpg')
            .getData();
        _courses[tmp] = Tuple2(utf8.decode(title!), Image.memory(image!));
      }
    }

    setState(() {
      if (_courses.isNotEmpty) {
        downloadCourses = true;
      }
    });
  }

  ///toggles the bool 'favourite' to change the displayed icon, updates db and cache
  void toggleLikeMentor() async {
    String username = Preferences.getUsername()!;

    favourite = !favourite;

    if (favourite) {
      //add the new favourite mentor in db
      await FirestoreCrud.updateFavouriteMentors(username, _mentor, 'add');
    } else {
      //remove the favourite mentor from db
      await FirestoreCrud.updateFavouriteMentors(username, _mentor, 'remove');
    }

    //update cache
    await Preferences.setMentors(username);

    setState(() {});
  }

  ///1->4294198070=red, 2->4294961979=yellow, 3->4283215696=green
  ///Values obtained by using Colors.yellow.value
  Color convertColor(int level) {
    Color result;

    int colorCode = 0;
    switch (level) {
      case 1: //hard - red
        colorCode = 4294198070;
        break;
      case 2: //medium - yellow
        colorCode = 4294961979;
        break;
      case 3: //easy - green
        colorCode = 4283215696;
        break;
      default:
        break;
    }

    result = Color(colorCode);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Mentor Page",
      ),
      body: ListView(
        children: [
          //IMAGES
          Stack(
            children: [
              SizedBox(
                  height: _backgroundPadding,
                  width: MediaQuery.sizeOf(context).width,
                  child: downloadMentorPics
                      ? Image(
                          image: background.image,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                        )
                      : Container()),
              Container(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      2 * AppLayout.kModalHorizontalPadding,
                      2 * _backgroundPadding / 3,
                      0,
                      0),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppLayout.kProfilePicRadiusLarge),
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
          //INFO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      AppLayout.kModalHorizontalPadding,
                      AppLayout.kHeightSmall,
                      0,
                      0),
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
                margin: const EdgeInsets.only(
                    right: AppLayout.kModalHorizontalPadding),
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
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppLayout.kModalHorizontalPadding, 0, 0, 0),
            child: const Text(
              "Upcoming Classes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //UPCOMING CLASSES
          ContainerShadow(
            margin: const EdgeInsetsDirectional.fromSTEB(
                AppLayout.kHorizontalPadding,
                0,
                AppLayout.kHorizontalPadding,
                0),
            child: downloadClasses
                ? ListView.builder(
                    itemCount: _upcomingClasses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.asset(
                          'assets/hobbies/$_hobby.png',
                          height: AppLayout.kHobbyDimension,
                          fit: BoxFit.cover,
                          color: convertColor(int.parse(
                              _upcomingClasses[index].split(';;')[0])),
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
                  )
                : const SizedBox(
                    height: AppLayout.kIconDimension,
                  ),
          ),
          Container(
            height: AppLayout.kHeight,
          ),
          Container(
            alignment: AlignmentDirectional.topStart,
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppLayout.kModalHorizontalPadding, 0, 0, 0),
            child: const Text(
              "Courses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: AppLayout.kHeightSmall,
          ),
          const Divider(
            height: 0,
            indent: AppLayout.kHorizontalPadding,
            endIndent: AppLayout.kHorizontalPadding,
            thickness: 2,
          ),
          //COURSES
          Container(
              child: downloadCourses
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _courses.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        return MyIconButton(
                          onTap: () {
                            Widget newScreen = CoursesPage(
                                mentor: _mentor,
                                title: _courses.values
                                    .elementAt(index)
                                    .item1
                                    .split(';;')[1],
                                courseID: _courses.keys.elementAt(index));
                            Navigator.push(
                              context,
                              ScreenTransition(
                                builder: (context) => newScreen,
                              ),
                            );
                          },
                          icon: ContainerShadow(
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, AppLayout.kHeightSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height:
                                      120, // Adjust the image height as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const ui.Color(0xffffcc80),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .shadowColor
                                            .withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: Image(
                                    image: _courses.values
                                        .elementAt(index)
                                        .item2
                                        .image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        8), // Spacing between image and title
                                Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal: 8),
                                  child: Text(
                                      _courses.values
                                          .elementAt(index)
                                          .item1
                                          .split(';;')[1],
                                      style: const TextStyle(fontSize: 17)),
                                ),
                                Expanded(
                                    child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      color: convertColor(int.parse(_courses
                                          .values
                                          .elementAt(index)
                                          .item1
                                          .split(';;')[0])),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container())
        ],
      ),
    );
  }
}
