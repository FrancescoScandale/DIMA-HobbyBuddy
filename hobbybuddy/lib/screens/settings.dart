import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/screens/change_password.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/screens/login.dart';

String logo = 'assets/logo.png';

class Settings extends StatefulWidget {
  const Settings(
      {Key? key, required this.username, required this.profilePicture})
      : super(key: key);

  final String username;
  final Image profilePicture;

  @override
  State<Settings> createState() =>
      _SettingsScreenState(username, profilePicture);
}

class _SettingsScreenState extends State<Settings> {
  late String _username;
  late Image _propic;

  _SettingsScreenState(String user, Image propic) {
    _username = user;
    _propic = propic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Settings",
      ),
      body: ListView(
        children: [
          FractionallySizedBox(
            widthFactor: MediaQuery.of(context).size.width < 600
                ? 1.0
                : 700 / MediaQuery.of(context).size.width,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 160,
              decoration: const BoxDecoration(
                color: ui.Color.fromRGBO(250, 220, 204, 0.5),
                //color: Color.fromARGB(255, 238, 139, 96),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Image(
                            image: _propic.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                //color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 4, 0, 0),
                              child: Text(
                                Preferences.getEmail()!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  //color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //padding to the next section
          Container(
            height: AppLayout.kPaddingFromCreate,
          ),
          FractionallySizedBox(
            widthFactor: MediaQuery.of(context).size.width < 600
                ? 1.0
                : 700 / MediaQuery.of(context).size.width,
            child: ContainerShadow(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Dark mode",
                    ),
                    value: Preferences.getBool('isDark'),
                    onChanged: (newValue) {
                      setState(() {
                        Provider.of<ThemeManager>(context, listen: false)
                            .toggleTheme(newValue);
                      });
                    },
                    secondary: const Icon(Icons.dark_mode_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit profile"),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () async {
                      Widget newScreen = const EditProfileScreen();
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_open),
                    title: const Text("Change password"),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      Widget newScreen = const ChangePasswordScreen();
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          //padding to the next section
          Container(
            height: AppLayout.kPaddingFromCreate,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200, // Adjust the width as per your requirement
              height: 50, // Adjust the height as per your requirement
              child: ElevatedButton(
                onPressed: () async {
                  Widget newScreen = const LogInScreen(); //Main();
                  // ignore: use_build_context_synchronously
                  await Navigator.of(context, rootNavigator: true).push(
                    ScreenTransition(
                      builder: (context) => newScreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    //color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
