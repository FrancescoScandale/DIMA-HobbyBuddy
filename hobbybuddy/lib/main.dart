import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';
import 'themes/layout.dart';
import 'themes/light_dark.dart';
import 'themes/app_theme.dart';
import 'package:hobbybuddy/services/firebase_user.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';

String logo = 'assets/logo.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Preferences.init();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  runApp(MultiProvider(providers: [
    // DARK/LIGHT THEME
    ChangeNotifierProvider<ThemeManager>(create: (context) => ThemeManager())
  ], child: const Settings()));

  WidgetsFlutterBinding.ensureInitialized();
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HobbyBuddy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home: Directionality(
        textDirection:
            TextDirection.ltr, // Replace with the appropriate text direction
        child: Scaffold(
          appBar: MyAppBar(
            title: "Settings",
            upRightActions: [
              MyIconButton(
                margin: const EdgeInsets.only(
                    right: AppLayout.kModalHorizontalPadding),
                icon: Icon(Icons.logout,
                    color: Theme.of(context).primaryColorLight),
                onTap: () async {
                  await Provider.of<FirebaseUser>(context, listen: false)
                      .signOut();
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
        ),
      ),
    );
  }
}

class MartaScreen extends StatelessWidget {
  const MartaScreen({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "hobbybuddy",
      home: Directionality(
        textDirection:
            TextDirection.ltr, // Replace with the appropriate text direction
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  logo, // Replace with your logo image path
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 16),
                // Buffering Icon
                const CircularProgressIndicator(backgroundColor: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      home: Scaffold(
          appBar: AppBar(title: const Text("Hello World")),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              HelloWorld(),
              HelloWorldGenerator(10),
              HelloWorldPlus(10),
              HelloWorldPlus.withBlue(11),
            ],
          ))),
    );
  }
}

class HelloWorld extends StatelessWidget {
  const HelloWorld({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text("Hello World",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500));
  }
}

class HelloWorldPlus extends StatelessWidget {
  final int number;
  final Color color;

  const HelloWorldPlus(this.number, {this.color = Colors.red, Key? key})
      : super(key: key);

  // Named Constructor
  const HelloWorldPlus.withBlue(this.number, {Key? key})
      : color = Colors.blue,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Hello World $number",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: color),
    );
  }
}

class HelloWorldGenerator extends StatelessWidget {
  final int count;

  const HelloWorldGenerator(this.count, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dart support generic types
    List<Widget> childList = [];
    for (int i = 0; i < count; i++) {
      childList.add(HelloWorldPlus(i,
          color: Color.fromRGBO(
            16 * i % 255, // red
            32 * i % 255, // green
            64 * i % 255, // blue
            1.0, // opacity
          )));
    }
    return Column(children: childList);
  }
}*/

class ShowLoginCredentials extends StatelessWidget {
  final String title = "HobbyBuddy";

  const ShowLoginCredentials({Key? key}) : super(key: key);

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              document['username'],
              style: Theme.of(context).textTheme.headlineSmall,
            ), // Text
          ), // Expanded
          Expanded(
            child: Text(
              document['password'],
              style: Theme.of(context).textTheme.headlineSmall,
            ), // Text
          ), // Expanded
        ],
      ),
    ); // ListTile
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "hobbybuddy",
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('credentials')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Data not found :(');
              return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                    _buildListItem(context, snapshot.data!.docs[index]),
              );
            }),
      ),
    );
  }
}

/*class ProfileData extends StatelessWidget {
  const ProfileData({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<FirebaseUser>(context, listen: false)
          .getCurrentUserStream(),
      builder: (
        BuildContext context,
        AsyncSnapshot<UserModel> snapshot,
      ) {
        UserModel userData = snapshot.data!;
        return Column(
          children: [
            ProfilePicFromData(
              userData: userData,
              radius: AppLayout.kProfilePicRadius,
            ),
            const SizedBox(height: AppLayout.kHeight),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  userData.username,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${userData.name} ${userData.surname}",
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}*/

