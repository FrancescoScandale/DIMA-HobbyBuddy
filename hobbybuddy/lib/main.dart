import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //we use CLOUD FIRESTORE as a db

String logo = 'assets/logo.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //runApp(const MartaScreen());
  //runApp(const ShowLoginCredentials()); //retrieves data from db and builds a list
  //runApp(const LoginScreen()); //retrives all data from a collection and saves it in a map which uses it later
  runApp(const BetterLoginScreen()); //retrieves specific data from db using a query and checks if any data retrieved (i.e. if the query had results)
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
                  //check if credentials present in db
                  FirebaseFirestore.instance.collection("credentials")
                      .where("username", isEqualTo: username.text)
                      .where("password", isEqualTo: password.text)
                      .get().then((values) {
                        if (values.docs.isNotEmpty) {
                          check = true;
                        }
                      });
                  if (check) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Found!')),
                    );
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
}
