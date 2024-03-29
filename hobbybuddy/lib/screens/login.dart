import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/firebase_auth.dart';
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
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = AuthenticationCrud.auth;
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

  Future<bool> _signInWithEmailAndPassword() async {
    try {
      String email = await FirestoreCrud.getEmail(username.text);

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.text,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: MediaQuery.of(context).size.width < 600
                ? 1.0
                : 700 / MediaQuery.of(context).size.width,
            child: TextFormField(
              key: const Key("u_field"),
              controller: username,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.face),
                border: OutlineInputBorder(),
                labelText: 'Username',
                labelStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
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
          ),
          const SizedBox(height: 25),
          FractionallySizedBox(
            widthFactor: MediaQuery.of(context).size.width < 600
                ? 1.0
                : 700 / MediaQuery.of(context).size.width,
            child: TextFormField(
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
                    _passwordInvisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
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
                    if (_formKey.currentState!.validate()) {
                      bool check = await _signInWithEmailAndPassword();
                      if (check) {
                        //retrieve data
                        await Preferences.setUsername(username.text);
                        await Preferences.setHobbies(username.text);
                        await Preferences.setMentors(username.text);
                        await Preferences.setEmail(username.text);
                        await Preferences.setLocation(username.text);
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
