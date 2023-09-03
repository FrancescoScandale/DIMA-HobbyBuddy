import 'dart:convert';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobbybuddy/screens/add_milestone.dart';
import 'package:hobbybuddy/screens/homepage_hobby.dart';
import 'package:hobbybuddy/screens/homepage_mentor.dart';
import 'package:hobbybuddy/screens/settings.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tuple/tuple.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.user}) : super(key: key);

  final String user;

  @override
  State<UserPage> createState() => _UserPageState(user);
}

class _UserPageState extends State<UserPage> {
  late String _username;
  late String _name;
  late String _surname;
  final double _backgroundPadding = 250;
  late String _location = '';
  List<String> _hobbies = [];
  List<String> _mentors = [];
  Map<String, Image> _mentorsPics = {};
  Map<String, Tuple2<String, Image>> _milestones = {};
  late Image propic;
  late Image background;
  bool downloadHobbies = false;
  bool downloadMentors = false;
  bool downloadMilestones = false;
  bool downloadLocations = false;
  bool downloadUserPics = false;
  bool downloadNameSurname = false;

  _UserPageState(String user) {
    _username = user;
  }

  @override
  void initState() {
    getUserPics();
    getNameSurname();
    computeLocation();
    getHobbies();
    getMentors();
    getMilestones();
    super.initState();
  }

  void getHobbies() async {
    _hobbies = await FirestoreCrud.getUserData(_username, 'hobbies');
    setState(() {
      if (_hobbies.isNotEmpty) {
        downloadHobbies = true;
      }
    });
  }

  void getMentors() async {
    _mentors = await FirestoreCrud.getUserData(_username, 'mentors');

    if (_mentors.isNotEmpty) {
      for (int i = 0; i < _mentors.length; i++) {
        Uint8List? image = await StorageCrud.getStorage()
            .ref()
            .child('Mentors/${_mentors[i]}/propic.jpg')
            .getData();
        _mentorsPics[_mentors[i]] = Image.memory(image!);
      }

      setState(() {
        downloadMentors = true;
      });
    }
  }

  void computeLocation() async {
    List<String> coordinates = Preferences.getLocation()!;
    List<Placemark> addresses = await placemarkFromCoordinates(
        double.parse(coordinates[0]), double.parse(coordinates[1]));
    _location = '${addresses[0].street!}, ${addresses[0].locality!}';

    setState(() {
      downloadLocations = true;
    });
  }

  void getMilestones() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Users/$_username/milestones/')
        .listAll();

    if (result.prefixes.isNotEmpty) {
      int len = (result.prefixes[0].fullPath.split('/')).length;
      for (Reference prefs in result.prefixes) {
        String tmp = prefs.fullPath.split('/')[len - 1];
        Uint8List? cap = await StorageCrud.getStorage()
            .ref()
            .child('Users/$_username/milestones/$tmp/caption.txt')
            .getData();
        Uint8List? image = await StorageCrud.getStorage()
            .ref()
            .child('Users/$_username/milestones/$tmp/pic.jpg')
            .getData();
        _milestones[tmp] = Tuple2(utf8.decode(cap!), Image.memory(image!));
      }

      setState(() {
        downloadMilestones = true;
      });
    }
  }

  void getUserPics() async {
    ListResult result = await StorageCrud.getStorage()
        .ref()
        .child('Users/$_username/')
        .listAll();
    if (result.items.isNotEmpty) {
      Uint8List? propicData = await StorageCrud.getStorage()
          .ref()
          .child('Users/$_username/propic.jpg')
          .getData();
      Uint8List? backgroundData = await StorageCrud.getStorage()
          .ref()
          .child('Users/$_username/background.jpg')
          .getData();

      propic = Image.memory(propicData!);
      background = Image.memory(backgroundData!);
    } else {
      propic = Image.asset('assets/pics/propic.jpg');
      background = Image.asset('assets/pics/lowqualitybackground.jpg');
    }

    setState(() {
      downloadUserPics = true;
    });
  }

  void getNameSurname() async {
    List<String> result = await FirestoreCrud.getUserNameSurname(_username);

    _name = result[0];
    _surname = result[1];

    setState(() {
      downloadNameSurname = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: "Profile Page",
        ),
        body: RefreshIndicator(
            child: ListView(
              children: [
                Stack(
                  //IMAGES
                  children: [
                    SizedBox(
                        height: _backgroundPadding,
                        width: MediaQuery.sizeOf(context).width,
                        child: downloadUserPics
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
                          borderRadius: BorderRadius.circular(
                              AppLayout.kProfilePicRadius),
                          child: downloadUserPics
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
                            AppLayout.kModalHorizontalPadding,
                            AppLayout.kHeightSmall,
                            0,
                            0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              downloadNameSurname ? _name + ' ' + _surname : '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _location,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                    Preferences.getUsername() == _username && downloadUserPics
                        ? MyIconButton(
                            margin: const EdgeInsets.only(right: 30),
                            onTap: () async {
                              Widget newScreen = Settings(
                                username: _username,
                                profilePicture: propic,
                              );
                              Navigator.push(
                                context,
                                ScreenTransition(
                                  builder: (context) => newScreen,
                                ),
                              ).then((_) {
                                downloadUserPics = false;
                                downloadNameSurname = false;
                                getUserPics();
                                getNameSurname();
                              });
                              ;
                            },
                            icon: const Icon(
                              Icons.settings_sharp,
                              size: 1.2 * AppLayout.kButtonHeight,
                            ))
                        : Container()
                  ],
                ),
                ContainerShadow(
                  //HOBBIES
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            AppLayout.kHorizontalPadding, 0, 0, 0),
                        child: Text(
                          'Hobbies',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: AppLayout.kIconDimension,
                          child: ListView.builder(
                            itemCount: _hobbies.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal:
                                              AppLayout.kHorizontalPadding),
                                  width: AppLayout.kIconDimension,
                                  child: SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      MyIconButton(
                                          icon: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                color: ui.Color(0xffffcc80),
                                                child: downloadHobbies
                                                    ? Image.asset(
                                                        'assets/hobbies/${_hobbies[index]}.png',
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Container(
                                                        height: AppLayout
                                                                .kIconDimension *
                                                            0.8,
                                                        width: AppLayout
                                                                .kIconDimension *
                                                            0.8,
                                                      ),
                                              )),
                                          onTap: () {
                                            Widget newScreen = HomePageHobby(
                                              hobby: _hobbies[index],
                                            );
                                            Navigator.push(
                                              context,
                                              ScreenTransition(
                                                builder: (context) => newScreen,
                                              ),
                                            ).then((value) {
                                              setState(() {
                                                downloadHobbies = false;
                                              });
                                              getHobbies();
                                            });
                                          }),
                                      downloadHobbies
                                          ? Text(
                                              _hobbies[index],
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Container()
                                    ],
                                  )));
                            },
                          ))
                    ],
                  ),
                ),
                ContainerShadow(
                  //MENTORS
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            AppLayout.kHorizontalPadding, 0, 0, 0),
                        child: Text(
                          'Mentors',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: AppLayout.kIconDimension + 10,
                          child: ListView.builder(
                            itemCount: _mentors.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                          horizontal:
                                              AppLayout.kHorizontalPadding),
                                  width: AppLayout.kIconDimension * 1.1,
                                  child: SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      MyIconButton(
                                          icon: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Container(
                                                  color: ui.Color(0xffffcc80),
                                                  child: downloadMentors
                                                      ? Image(
                                                          key: Key(
                                                              _mentors[index]),
                                                          image: _mentorsPics[
                                                                  _mentors[
                                                                      index]]!
                                                              .image,
                                                          fit: BoxFit.cover,
                                                          height: AppLayout
                                                                  .kIconDimension *
                                                              0.8,
                                                          width: AppLayout
                                                                  .kIconDimension *
                                                              0.8,
                                                        )
                                                      : Container(
                                                          height: AppLayout
                                                                  .kIconDimension *
                                                              0.8,
                                                          width: AppLayout
                                                                  .kIconDimension *
                                                              0.8,
                                                        ))),
                                          onTap: () {
                                            Widget newScreen = MentorPage(
                                              mentor: _mentors[index],
                                            );
                                            Navigator.push(
                                              context,
                                              ScreenTransition(
                                                builder: (context) => newScreen,
                                              ),
                                            ).then((value) {
                                              setState(() {
                                                downloadMentors = false;
                                              });
                                              getMentors();
                                            });
                                          }),
                                      downloadMentors
                                          ? Text(
                                              _mentors[index],
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Container()
                                    ],
                                  )));
                            },
                          ))
                    ],
                  ),
                ),
                Column(
                  //MILESTONES
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: AppLayout.kHeight,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              AppLayout.kHorizontalPadding, 0, 0, 0),
                          child: Text(
                            'Milestones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, AppLayout.kHorizontalPadding, 0),
                            child: SizedBox(
                              width: 125,
                              height: 35,
                              child: MyButton(
                                text: '+ Milestone',
                                edge: 5,
                                onPressed: () async {
                                  Widget newScreen =
                                      AddMilestone(user: _username);
                                  Navigator.push(
                                    context,
                                    ScreenTransition(
                                      builder: (context) => newScreen,
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      downloadMilestones = false;
                                    });
                                    getMilestones();
                                  });
                                },
                              ),
                            ))
                      ],
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
                    downloadMilestones
                        ? SizedBox(
                            child: ListView.builder(
                            reverse: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _milestones.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ContainerShadow(
                                  child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      downloadMilestones
                                          ? _milestones.keys.toList()[index]
                                          : '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      downloadMilestones
                                          ? _milestones.values
                                              .toList()[index]
                                              .item1
                                          : '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  downloadMilestones
                                      ? Image(
                                          image: _milestones.values
                                              .toList()[index]
                                              .item2
                                              .image,
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.8,
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.center,
                                        )
                                      : Container(
                                          height:
                                              AppLayout.kIconDimension * 0.8,
                                          width: AppLayout.kIconDimension * 0.8,
                                        )
                                ],
                              ));
                            },
                          ))
                        : Container(
                            height: AppLayout.kIconDimension * 0.8,
                            width: AppLayout.kIconDimension * 0.8,
                          )
                  ],
                ),
              ],
            ),
            onRefresh: () async {
              getHobbies();
              getMentors();
            }));
  }
}
