import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';
import 'package:hobbybuddy/services/firebase_user.dart';
import 'package:hobbybuddy/models/user_model.dart';

import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:hobbybuddy/widgets/profile_picture.dart';
import 'package:hobbybuddy/themes/light_dark.dart';
import 'package:hobbybuddy/themes/layout.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Settings",
        upRightActions: [
          MyIconButton(
            margin:
                const EdgeInsets.only(right: AppLayout.kModalHorizontalPadding),
            icon:
                Icon(Icons.logout, color: Theme.of(context).primaryColorLight),
            onTap: () async {
              await Provider.of<FirebaseUser>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          controller: ScrollController(),
          children: [
            Container(height: AppLayout.kPaddingFromCreate),
            //const ProfileData(),
            ContainerShadow(
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
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit profile"),
                    trailing: const Icon(Icons.navigate_next),
                    /*onTap: () async {
                      Stream<UserModel> stream =
                          Provider.of<FirebaseUser>(context, listen: false)
                              .getCurrentUserStream();
                      UserModel userData = await stream.first;
                      Widget newScreen = EditProfileScreen(userData: userData);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },*/
                  ),
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text("Change password"),
                    trailing: const Icon(Icons.navigate_next),
                    /*onTap: () {
                      Widget newScreen = const ChangePasswordScreen();
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        ScreenTransition(
                          builder: (context) => newScreen,
                        ),
                      );
                    },*/
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Sign Out"),
                    //onTap: () async {
                    //await Provider.of<FirebaseUser>(context, listen: false)
                    // .signOut();
                    //},
                  ),
                ],
              ),
            ),
            Container(height: AppLayout.kPaddingFromCreate),
          ],
        ),
      ),
    );
  }
}
