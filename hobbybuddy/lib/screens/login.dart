import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:hobbybuddy/main.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      hideNavigation: true,
      child: Scaffold(
        body: SingleChildScrollView(
          controller: ScrollController(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome to Hobby Buddy!",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Log In",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _passwordInvisible = true;
  bool pressed = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: const Key("u_field"),
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
                setState(() {
                  pressed = false;
                });
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          TextFormField(
            key: const Key("p_field"),
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
                  _passwordInvisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            // The validator receives the text that the user has entered.
            validator: (value2) {
              if (value2 == null || value2.isEmpty) {
                setState(() {
                  pressed = false;
                });
                return 'Please enter your password';
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
                  key: const Key("go_login"),
                  onPressed: () async {
                    setState(() {
                      pressed = true;
                    });
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      bool check = false;
                      //check if credentials present in db
                      await FirestoreCrud.getUserPwd(
                              username.text, password.text)
                          .then((values) async {
                        if (values!.docs.isNotEmpty) {
                          check = true;

                          //retrieve data
                          await Preferences.setUsername(username.text);
                          await Preferences.setHobbies(username.text);
                          await Preferences.setMentors(username.text);
                          await Preferences.setEmail(username.text);
                        }
                      });
                      if (check) {
                        Widget newScreen = const BottomNavigationBarApp();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          ScreenTransition(
                            builder: (context) => newScreen,
                          ),
                        );
                      } else {
                        setState(() {
                          pressed = false;
                        });
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account not found...")),
                        );
                      }
                    }
                  },
                  child: Text(
                    pressed ? 'Checking...' : 'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
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
                key: const Key("go_sign_up"),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
