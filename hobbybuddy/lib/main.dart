import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:hobbybuddy/firebase_options.dart';

import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';

import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:hobbybuddy/screens/home_page.dart';
import 'package:hobbybuddy/screens/maps.dart';
import 'package:hobbybuddy/screens/login.dart';
import 'package:hobbybuddy/screens/homepage_user.dart';
import 'package:hobbybuddy/screens/friends_list.dart';

String logo = 'assets/logo.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Preferences.init();
  runApp(MultiProvider(providers: [
    // DARK/LIGHT THEME
    ChangeNotifierProvider<ThemeManager>(create: (context) => ThemeManager()),
  ], child: const Main()));
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      initialRoute: '/',
      home: const Scaffold(
        body: LoginForm(),
      ),
    );
  }
}

class BottomNavigationBarApp extends StatefulWidget {
  const BottomNavigationBarApp({super.key});

  @override
  State<BottomNavigationBarApp> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBarApp> {
  int currentIndex = 0;

  final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CupertinoTabScaffold(
            tabBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return CupertinoTabView(
                    navigatorKey: firstTabNavKey,
                    builder: (context) => const HomePScreen(),
                  );
                case 1:
                  return CupertinoTabView(
                    navigatorKey: secondTabNavKey,
                    builder: (context) => const MapsScreen(),
                  );
                case 2:
                  return CupertinoTabView(
                    navigatorKey: thirdTabNavKey,
                    builder: (context) => const MyFriendsScreen(),
                  );
                case 3:
                  return CupertinoTabView(
                    navigatorKey: fourthTabNavKey,
                    builder: (context) =>
                        UserPage(user: Preferences.getUsername()!),
                  );
                default:
                  return const CupertinoTabView();
              }
            },
            tabBar: CupertinoTabBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Maps',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: 'My Friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                // back home only if not switching tab
                if (currentIndex == index) {
                  switch (index) {
                    case 0:
                      firstTabNavKey.currentState?.popUntil((r) => r.isFirst);
                      break;
                    case 1:
                      secondTabNavKey.currentState?.popUntil((r) => r.isFirst);
                      break;
                    case 2:
                      thirdTabNavKey.currentState?.popUntil((r) => r.isFirst);
                      break;
                    case 3:
                      fourthTabNavKey.currentState?.popUntil((r) => r.isFirst);
                      break;
                  }
                }
                currentIndex = index;
              },
            ),
          ),
        ],
      ),
    );
  }
}
