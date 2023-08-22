import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/preferences.dart';

import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/screens/sign_up.dart';
import 'package:hobbybuddy/main.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // todo: remove appBar
      body: ResponsiveWrapper(
        hideNavigation: true,
        child: LoginForm(),
      ),
    );
  }
}

// Create a Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}
//}

// Create a corresponding State class.
// This class holds data related to the form.
class _LoginFormState extends State<LoginForm> {
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
      controller: PrimaryScrollController.of(context),
      child: ListView(
        controller: PrimaryScrollController.of(context),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 60),
          Image.asset(
            'assets/logo.png', // Replace with your logo image path
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
                            await FirebaseCrud.getUserPwd(
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
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Account not found...")),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
