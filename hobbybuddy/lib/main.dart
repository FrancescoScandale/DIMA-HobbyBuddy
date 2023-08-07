//import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobbybuddy/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';
import 'themes/layout.dart';
import 'themes/light_dark.dart';
import 'themes/app_theme.dart';
//import 'package:hobbybuddy/services/firebase_user.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
//import 'package:hobbybuddy/widgets/button_icon.dart';

import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';
import 'package:flutter/cupertino.dart';

import 'package:hobbybuddy/screens/change_password.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/screens/sign_up.dart';

String logo = 'assets/logo.png';
const LatLng startingLocation =
    LatLng(45.464037, 9.190403); //location taken from 45.464037, 9.190403
const double startingZoom = 17;

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
  ], child: const BottomNavigationBarApp()));
  //runApp(const MapsScreen());BetterLoginScreen()
}

class BottomNavigationBarApp extends StatelessWidget {
  const BottomNavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      initialRoute: '/',
      home: const BottomNavigationBarTest(),
    );
  }
}

class BottomNavigationBarTest extends StatefulWidget {
  const BottomNavigationBarTest({super.key});

  @override
  State<BottomNavigationBarTest> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBarTest> {
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
    0: MapsScreen(),
    1: MapsScreen(),
    2: Settings(),
    3: Settings(),
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
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'maps',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'favorites',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'profile',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              switch (index) {
                case 0:
                  return CupertinoTabView(
                    navigatorKey: firstTabNavKey,
                    builder: (context) => const MapsScreen(),
                  );
                case 1:
                  return CupertinoTabView(
                    navigatorKey: secondTabNavKey,
                    builder: (context) => const MapsScreen(),
                  );
                case 2:
                  return CupertinoTabView(
                    navigatorKey: thirdTabNavKey,
                    builder: (context) => const Settings(),
                  );
                case 3:
                  return CupertinoTabView(
                    navigatorKey: fourthTabNavKey,
                    builder: (context) => const Settings(),
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
      ),
      body: ListView(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: 160,
            decoration: BoxDecoration(
              color: ui.Color(0xffffcc80),
              //color: Color.fromARGB(255, 238, 139, 96),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 40, 20, 0),
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
                      padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.asset(
                          logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mr. Rogers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              //color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: Text(
                              'Mr.Rogers@gmail.com',
                              style: TextStyle(
                                fontSize: 18,
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
          Container(
            height: AppLayout.kPaddingFromCreate,
          ),
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
                /*ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sign Out"),
                  //onTap: () async {
                  //await Provider.of<FirebaseUser>(context, listen: false)
                  // .signOut();
                  //},
                ),*/
              ],
            ),
          ),
          Container(
            height: AppLayout.kPaddingFromCreate,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 200, // Adjust the width as per your requirement
              height: 50, // Adjust the height as per your requirement
              child: ElevatedButton(
                onPressed: () {
                  Widget newScreen = const BetterLoginScreen();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context, rootNavigator: true).push(
                    //navigator.push( context, == old version
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
                child: Text(
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
            stream: FirebaseFirestore.instance.collection('credentials').snapshots(),
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
    await FirebaseFirestore.instance.collection("credentials").get().then(
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

class BetterLoginScreen extends StatelessWidget {
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
}

// Create a Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  Map<String, String> credentials = {};
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _passwordInvisible = true;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scrollbar(
      child: ListView(
        controller: ScrollController(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 60),
          Image.asset(
            logo, // Replace with your logo image path
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome to Hobby Buddy!",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Log In",
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Form(
            key: _formKey,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.face),
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    labelStyle: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value1) {
                    if (value1 == null || value1.isEmpty) {
                      return 'Username not found';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: password,
                  obscureText: _passwordInvisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open),
                    hintText: 'Password',
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordInvisible = !_passwordInvisible;
                        });
                      },
                      icon: Icon(
                        _passwordInvisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value2) {
                    if (value2 == null || value2.isEmpty) {
                      return 'Password not found';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            bool check = false;
                            //check if credentials present in db
                            await FirebaseFirestore.instance
                                .collection("credentials")
                                .where("username", isEqualTo: username.text)
                                .where("password", isEqualTo: password.text)
                                .get()
                                .then((values) {
                              if (values.docs.isNotEmpty) {
                                check = true;
                              }
                            });
                            if (check) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Found!')),
                              );

                              Widget newScreen = const BottomNavigationBarApp();
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                ScreenTransition(
                                  builder: (context) => newScreen,
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Data not found...")),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      key: const Key("log_in_to_sign_up_screen"),
                      onPressed: () async {
                        Widget newScreen = const SignUpScreen();
                        await Navigator.of(context, rootNavigator: false).push(
                          ScreenTransition(
                            builder: (context) => newScreen,
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up here",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MapsScreen extends StatelessWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Buddy Finder';

    return Scaffold(
      //debugShowCheckedModeBanner: false,

      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: const MapClass(),
    );
  }
}

class MapClass extends StatefulWidget {
  const MapClass({Key? key}) : super(key: key);

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<MapClass> {
  List<Marker> mapMarkers = [];
  late GoogleMapController mapController; //used to update the camera position
  //useful because the map lags and the button uses this to go back to the initial position

  static const CameraPosition _goHome = CameraPosition(
    target: startingLocation,
    zoom: startingZoom,
  );

  Future<void> _goHomeFunction() async {
    await mapController.animateCamera(CameraUpdate.newCameraPosition(_goHome));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void createMarker(String id, double lat, double lng, String windowTitle,
      String windowSnippet) async {
    Marker marker;

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/hobbies/$windowTitle.png', 50);

    marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: windowTitle,
        snippet: windowSnippet,
        //onTap: ... -> TODO: this function could be used to see the buddy's profile
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );

    setState(() {
      mapMarkers.add(marker);
    });
    return;
  }

  //TODO: only retrieve the markers from the hobbies the user is interested in
  Future<void> retrieveMarkers() async {
    await FirebaseFirestore.instance.collection("markers").get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          createMarker(doc.id, double.parse(doc["lat"]),
              double.parse(doc["lng"]), doc["title"], doc["snippet"]);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition:
            const CameraPosition(target: startingLocation, zoom: startingZoom),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          retrieveMarkers();
        },
        markers: mapMarkers.toSet(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          onPressed: _goHomeFunction,
          label: const Text('Go back home'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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

