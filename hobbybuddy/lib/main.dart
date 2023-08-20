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
import 'package:hobbybuddy/screens/favourites.dart';

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

    // GLOBAL TAB CONTROLLER
    ChangeNotifierProvider<CupertinoTabController>(
        create: (context) => CupertinoTabController()),
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

  void changeTab(int index) {
    // https://stackoverflow.com/questions/52298686/flutter-pop-to-root-when-bottom-navigation-tapped

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
    setState(() {
      currentIndex = index;
      Provider.of<CupertinoTabController>(context, listen: false).index =
          currentIndex;
    });
  }

  final Map<int, Widget> screens = {
    0: HomePScreen(),
    1: MapsScreen(),
    2: FavouritesScreen(),
    3: UserPage(user: Preferences.getUsername()!),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CupertinoTabScaffold(
            controller:
                Provider.of<CupertinoTabController>(context, listen: true),
            tabBar: CupertinoTabBar(
              onTap: changeTab,
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
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
            ),
            tabBuilder: (context, index) {
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
                    builder: (context) => const FavouritesScreen(),
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
          ),
        ],
      ),
    );
  }
}

/*class MartaScreen extends StatelessWidget {
  const MartaScreen({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "hobbybuddy",
      home: Directionality(
        textDirection: TextDirection.ltr, // Replace with the appropriate text direction
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
}*/

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

/*class ShowLoginCredentials extends StatelessWidget {
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
            ),
          ),
          Expanded(
            child: Text(
              document['password'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "hobbybuddy",
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Data not found :(');
              return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data!.docs[index]),
              );
            }),
      ),
    );
  }
}*/

/*class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'hobbybuddy';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  Map<String, String> credentials = {};
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> retrieveCredentials() async {
    //this version will set everything correctly
    await FirebaseFirestore.instance.collection("users").get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          credentials[doc["username"]] = doc["password"];
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    //credentials = snap.docs.first.data();
    print("credentials -> $credentials");
    print("keys -> ${credentials.keys}");
    print("passwords -> ${credentials.values}");
  }

  @override
  Widget build(BuildContext context) {
    retrieveCredentials();
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: username,
            // The validator receives the text that the user has entered.
            validator: (value1) {
              if (value1 == null || value1.isEmpty) {
                return 'username not found';
              }
              return null;
            },
          ),
          TextFormField(
            controller: password,
            // The validator receives the text that the user has entered.
            validator: (value2) {
              if (value2 == null || value2.isEmpty) {
                return 'password not found';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  bool check = false;
                  //check if credentials contained
                  if (credentials.containsKey(username.text) && credentials.containsValue(password.text)) {
                    if (credentials[username.text] == password.text) {
                      check = true;
                    }
                    if (check) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Found!')),
                      );
                    }
                  }
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (!check) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data not found...")),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}*/

/*class BetterLoginScreen extends StatelessWidget {
  const BetterLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'hobbybuddy';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const LoginForm(),
      ),
    );
  }
}*/

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
