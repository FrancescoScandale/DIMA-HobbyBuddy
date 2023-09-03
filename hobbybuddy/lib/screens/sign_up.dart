import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:geocoding/geocoding.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveWrapper(
        hideNavigation: true,
        child: SignUpForm(),
      ),
      appBar: MyAppBar(title: "Sign Up", upRightActions: []),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordInvisible = true;
  bool _isUsernameNotUnique = false;
  bool _isEmailNotUnique = false;
  final String localeIdentifier = 'it_IT';

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        controller: PrimaryScrollController.of(context),
        child: ListView(
          controller: PrimaryScrollController.of(context),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("username_field"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.face),
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            if (_isUsernameNotUnique)
              const Text(
                'This username is already taken. Please choose a different one.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("name_field"),
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.perm_identity),
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("surname_field"),
                controller: _surnameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.perm_identity),
                  border: OutlineInputBorder(),
                  labelText: 'Surname',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Surname cannot be empty';
                  }
                  locationFromAddress(_surnameController.text,
                      localeIdentifier: 'it_IT');
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("email_field"),
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                  labelText: 'E-mail',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an e-mail address';
                  }
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid e-mail address';
                  }
                  return null;
                },
              ),
            ),
            if (_isEmailNotUnique)
              const Text(
                'This email is already taken. Please choose a different one.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("password_field"),
                controller: _passwordController,
                obscureText: _passwordInvisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open),
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
                  labelText: 'Your password',
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
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("password_confirm_field"),
                obscureText: _passwordInvisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open),
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
                  labelText: 'Confirm password',
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
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppLayout.kHeightSmall),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 700 / MediaQuery.of(context).size.width,
              child: TextFormField(
                key: const Key("location_field"),
                controller: _locationController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.place_outlined),
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600
                  ? 1.0
                  : 200 / MediaQuery.of(context).size.width,
              child: MyButton(
                key: const Key("signup_button"),
                text: "Sign up",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String enteredUsername = _usernameController.text;
                    String enteredEmail = _emailController.text;

                    bool isUsernameUnique = await FirestoreCrud.isFieldUnique(
                        'username', enteredUsername);
                    bool isEmailUnique = await FirestoreCrud.isFieldUnique(
                        'email', enteredEmail);

                    if (isUsernameUnique && isEmailUnique) {
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      String username = _usernameController.text;
                      String name = _nameController.text;
                      String surname = _surnameController.text;
                      String location = await locationFromAddress(
                              _locationController.text,
                              localeIdentifier: localeIdentifier)
                          .then((value) {
                        return '${value[0].latitude},${value[0].longitude}';
                      });
                      // Username is unique, proceed with sign up logic
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: email, password: password);
                      await FirestoreCrud.addUserToFirestore(
                          email, username, name, surname, location);
                      setState(() {
                        _isUsernameNotUnique = false;
                        _isEmailNotUnique = false;
                      });
                      // Show the success dialog
                      // ignore: use_build_context_synchronously
                      _showSignUpSuccessDialog(context);
                    } else {
                      // Username is not unique, show a warning

                      setState(() {
                        _isUsernameNotUnique = !isUsernameUnique;
                        _isEmailNotUnique = !isEmailUnique;
                      });
                    }
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSignUpSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key("success_dialog"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for joining Hobby Hobby!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can now go back to the main page to log in.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the main page
              },
              child: const Text('Back to Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}
