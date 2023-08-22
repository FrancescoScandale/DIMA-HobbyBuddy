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
  bool favourite = false;
  bool completed = false;
  bool downloadMentorPics = false;
  bool downloadInfo = false;

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
    if (downloadMentorPics && downloadInfo) {
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

  @override
  Widget build(BuildContext context) {
    if (!completed) {
      favourite = Preferences.getMentors()!.contains(_mentor);
      getMentorPics();
      getInfo();
    }
    FirebaseCrud.getUpcomingClasses(_mentor);
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
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 2 * AppLayout.kModalHorizontalPadding, 0),
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
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: downloadInfo ? Image.asset(
                      'assets/hobbies/$_hobby.png',
                      height: AppLayout.kHobbyDimension,
                      fit: BoxFit.cover,
                      color: Colors.yellow, //yellow, grey, orangeAccent
                    ) : Container( //TODO: CHECK THESE DIMENSIONS
                      width: 10,
                      height: 10,
                    ),
                    title: Text('Skateboard'),
                    trailing: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text("12/7"),
                        Text("12:45")
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











/*

class _UserPageState extends State<UserPage> {
  late String _username;
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
  bool allowHobbies = false;

  _UserPageState(String user) {
    _username = user;
  }

  void checkCompletions() {
    if (downloadHobbies &&
        downloadMentors &&
        downloadMilestones &&
        downloadLocations &&
        downloadUserPics) {
      allowHobbies = true;

      setState(() {});
    }
  }

  void getHobbies() async {
    _hobbies = await FirebaseCrud.getUserData(_username, 'hobbies');
    downloadHobbies = true;
    checkCompletions();
  }

  void getMentors() async {
    _mentors = await FirebaseCrud.getUserData(_username, 'mentors');

    for (int i = 0; i < _mentors.length; i++) {
      String url = await FirebaseStorage.instance.ref().child('Mentors/${_mentors[i]}/propic.jpg').getDownloadURL();
      _mentorsPics[_mentors[i]] = Image.network(url);
    }

    downloadMentors = true;
    checkCompletions();
  }

  void computeLocation() async {
    List<String> coordinates = await FirebaseCrud.getAddress(_username);
    List<Placemark> addresses =
        await placemarkFromCoordinates(double.parse(coordinates[0]), double.parse(coordinates[1]));
    _location = addresses[0].street! + ', ' + addresses[0].locality!;

    downloadLocations = true;
    checkCompletions();
  }

  void getMilestones() async {
    ListResult result = await FirebaseStorage.instance.ref().child('Users/$_username/milestones/').listAll();

    int len = (result.prefixes[0].fullPath.split('/')).length;
    for (Reference prefs in result.prefixes) {
      String tmp = prefs.fullPath.split('/')[len - 1];
      Uint8List? cap =
          await FirebaseStorage.instance.ref().child('Users/$_username/milestones/$tmp/caption.txt').getData();
      Uint8List? image =
          await FirebaseStorage.instance.ref().child('Users/$_username/milestones/$tmp/pic.jpg').getData();
      _milestones[tmp] = Tuple2(utf8.decode(cap!), Image.memory(image!));
    }

    downloadMilestones = true;
    checkCompletions();
  }

  void getUserPics() async {
    Uint8List? propicData = await FirebaseStorage.instance.ref().child('Users/$_username/propic.jpg').getData();
    Uint8List? backgroundData = await FirebaseStorage.instance.ref().child('Users/$_username/background.jpg').getData();

    propic = Image.memory(propicData!);
    background = Image.memory(backgroundData!);

    downloadUserPics = true;
    checkCompletions();
  }

  static void newMilestone() {}

  @override
  Widget build(BuildContext context) {
    if (_location == '') {
      getUserPics();
      computeLocation();
      getHobbies();
      getMentors();
      getMilestones();
    }
    return Scaffold(
        appBar: const MyAppBar(
          title: "Profile Page",
        ),
        body: ListView(
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
                            fit: BoxFit.fitHeight,
                          )
                        : Container()),
                Container(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        2 * AppLayout.kModalHorizontalPadding, 2 * _backgroundPadding / 3, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppLayout.kProfilePicRadiusLarge),
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
                        AppLayout.kModalHorizontalPadding, AppLayout.kHeightSmall, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
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
                Preferences.getUsername() == _username
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
                          );
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
              //color: ui.Color(0xffffcc80), //TODO?
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(AppLayout.kHorizontalPadding, 0, 0, 0),
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
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppLayout.kHorizontalPadding),
                              width: AppLayout.kIconDimension,
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        color: ui.Color(0xffffcc80),
                                        child: allowHobbies
                                            ? Image.asset(
                                                'assets/hobbies/${_hobbies[index]}.png',
                                                fit: BoxFit.contain,
                                              )
                                            : Container(
                                                height: AppLayout.kIconDimension * 0.8,
                                                width: AppLayout.kIconDimension * 0.8,
                                              ),
                                      )),
                                  allowHobbies
                                      ? Text(
                                          _hobbies[index],
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        )
                                      : Container()
                                ],
                              ));
                        },
                      ))
                ],
              ),
            ),
            ContainerShadow(
              //MENTORS
              //color: ui.Color(0xffffcc80), //TODO?
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(AppLayout.kHorizontalPadding, 0, 0, 0),
                    child: Text(
                      'Mentors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: AppLayout.kIconDimension,
                      child: ListView.builder(
                        itemCount: _mentors.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppLayout.kHorizontalPadding),
                              width: AppLayout.kIconDimension * 1.1,
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                          color: ui.Color(0xffffcc80),
                                          child: downloadMentors
                                              ? Image(
                                                  image: _mentorsPics[_mentors[index]]!
                                                      .image, //TODO: prendere le immagini dal db
                                                  fit: BoxFit.cover,
                                                  height: AppLayout.kIconDimension * 0.8,
                                                  width: AppLayout.kIconDimension * 0.8,
                                                )
                                              : Container(
                                                  height: AppLayout.kIconDimension * 0.8,
                                                  width: AppLayout.kIconDimension * 0.8,
                                                ))),
                                  downloadMentors
                                      ? Text(
                                          _mentors[index],
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        )
                                      : Container()
                                ],
                              ));
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
                      padding: EdgeInsetsDirectional.fromSTEB(AppLayout.kHorizontalPadding, 0, 0, 0),
                      child: Text(
                        'Milestones',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, AppLayout.kHorizontalPadding, 0),
                        child: SizedBox(
                          width: 125,
                          height: 35,
                          child: MyButton(
                            text: '+ Milestone',
                            edge: 5,
                            onPressed: () async {
                              Widget newScreen = AddMilestone(user: _username);
                              Navigator.push(
                                context,
                                ScreenTransition(
                                  builder: (context) => newScreen,
                                ),
                              ).then((_) {
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
                              //color: ui.Color(0xffffcc80), //TODO?
                              child: Column(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  downloadMilestones ? _milestones.keys.toList()[index] : '',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  downloadMilestones ? _milestones.values.toList()[index].item1 : '',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                              downloadMilestones
                                  ? Image(
                                      image: _milestones.values.toList()[index].item2.image,
                                      width: MediaQuery.sizeOf(context).width * 0.8,
                                      fit: BoxFit.fitWidth,
                                      alignment: Alignment.center,
                                    )
                                  : Container(
                                      height: AppLayout.kIconDimension * 0.8,
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
        ));
  }
}
*/