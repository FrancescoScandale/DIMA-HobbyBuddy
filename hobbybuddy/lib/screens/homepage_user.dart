import 'dart:convert';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tuple/tuple.dart';

import '../widgets/app_bar.dart';

import 'package:hobbybuddy/screens/settings.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String _username =
      'Francesco Scandale'; //TODO: costruttore passa il nome da mostrare come username
  final double _backgroundPadding = 250;
  late String _location = '';
  List<String> _hobbies = Preferences.getHobbies()!;
  List<String> _mentors = Preferences.getMentors()!;
  Map<String, Image> _mentorsPics = {};
  bool downloadMentors = false;
  bool downloadMilestones = false;
  Map<String, Tuple2<String, Image>> _milestones = {};

  void computeLocation() async {
    // List<Location> coordinates;
    List<Placemark> addresses;
    // coordinates = await locationFromAddress("Via Eugenio Camerini 2, Milano");
    addresses = await placemarkFromCoordinates(45.4905447, 9.2303139);
    // print(coordinates);
    // print(addresses);
    _location = addresses[0].street! + ', ' + addresses[0].locality!;
    // print("$_location");
    // print('$_hobbies');
  }

  void getMentorsImages() async {
    for (int i = 0; i < _mentors.length; i++) {
      String url = await FirebaseStorage.instance
          .ref()
          .child('Mentors/${_mentors[i]}/propic.jpg')
          .getDownloadURL();
      _mentorsPics[_mentors[i]] = Image.network(url);
    }

    downloadMentors = true;
    if (downloadMentors && downloadMilestones) {
      setState(() {});
    }
  }

  void getMilestones() async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child('Users/${Preferences.getUsername()}/milestones/')
        .listAll();

    int len = (result.prefixes[0].fullPath.split('/')).length;
    for (Reference prefs in result.prefixes) {
      String tmp = prefs.fullPath.split('/')[len - 1];
      Uint8List? cap = await FirebaseStorage.instance
          .ref()
          .child(
              'Users/${Preferences.getUsername()}/milestones/$tmp/caption.txt')
          .getData();
      Uint8List? image = await FirebaseStorage.instance
          .ref()
          .child('Users/${Preferences.getUsername()}/milestones/$tmp/pic.jpg')
          .getData();
      _milestones[tmp] = Tuple2(utf8.decode(cap!), Image.memory(image!));
    }

    downloadMilestones = true;
    if (downloadMentors && downloadMilestones) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: used for the uploads
    DateTime timestamp = DateTime.timestamp();
    String ts = timestamp.toString().split('.')[0].replaceAll(' ', '_');
    // print('timestamp -> $timestamp');
    // print('used timestamp -> $ts');
    if (_location == '') {
      computeLocation();
      getMentorsImages();
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
                    child: const Image(
                      image: AssetImage(
                          'assets/pics/background.jpg'), //TODO: prendere l'immagine dal db
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                    )),
                Container(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        2 * AppLayout.kModalHorizontalPadding,
                        2 * _backgroundPadding / 3,
                        0,
                        0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppLayout.kProfilePicRadiusLarge),
                      child: Image.asset(
                        'assets/pics/propic.jpg', //TODO: prendere l'immagine dal db
                        width: AppLayout.kProfilePicRadiusLarge,
                        height: AppLayout.kProfilePicRadiusLarge,
                        fit: BoxFit.cover,
                      ),
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
                MyIconButton(
                    margin: const EdgeInsets.only(right: 30),
                    onTap: () async {
                      Widget newScreen = const Settings();
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
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppLayout.kHorizontalPadding),
                              width: AppLayout.kIconDimension,
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        color: const ui.Color(0xffffcc80),
                                        child: Image.asset(
                                          'assets/hobbies/${_hobbies[index]}.png',
                                          fit: BoxFit.contain,
                                        ),
                                      )),
                                  Text(
                                    _hobbies[index],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ));
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
                      height: AppLayout.kIconDimension,
                      child: ListView.builder(
                        itemCount: _mentors.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppLayout.kHorizontalPadding),
                              width: AppLayout.kIconDimension * 1.1,
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                          color: const ui.Color(0xffffcc80),
                                          child: downloadMentors
                                              ? Image(
                                                  image: _mentorsPics[
                                                          _mentors[index]]!
                                                      .image, //TODO: prendere le immagini dal db
                                                  fit: BoxFit.cover,
                                                  height:
                                                      AppLayout.kIconDimension *
                                                          0.8,
                                                  width:
                                                      AppLayout.kIconDimension *
                                                          0.8,
                                                )
                                              : Container(
                                                  height:
                                                      AppLayout.kIconDimension *
                                                          0.8,
                                                  width:
                                                      AppLayout.kIconDimension *
                                                          0.8,
                                                ))),
                                  Text(
                                    _mentors[index],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  )
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
                const Divider(
                  height: 0,
                  indent: AppLayout.kHorizontalPadding,
                  endIndent: AppLayout.kHorizontalPadding,
                  thickness: 2,
                ),
                downloadMilestones
                    ? ListView.builder(
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
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  downloadMilestones
                                      ? _milestones.values.toList()[index].item1
                                      : '',
                                  style: const TextStyle(
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
                                      //width: AppLayout.kPicDimension,
                                      width: MediaQuery.sizeOf(context).width *
                                          0.8,
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
                      )
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
