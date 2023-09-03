import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  String? username = Preferences.getUsername();
  bool _passwordInvisibleOld = true;
  bool _passwordInvisibleNew = true;

  Future<void> changePassword() async {
    String newPassword = _passwordController.text;
    // Retrieve the username from SharedPreferences
    //String? username = Preferences.getUsername();
    await FirestoreCrud.updatePassword(newPassword, username!);
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _currentPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Change password"),
      body: ResponsiveWrapper(
        child: Form(
          key: _formkey,
          child: Scrollbar(
            controller: PrimaryScrollController.of(context),
            child: ListView(
              controller: PrimaryScrollController.of(context),
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.kHorizontalPadding,
              ),
              children: [
                const SizedBox(height: 40),
                FractionallySizedBox(
                  widthFactor: MediaQuery.of(context).size.width < 600
                      ? 1.0
                      : 700 / MediaQuery.of(context).size.width,
                  child: TextFormField(
                    key: const Key("currentP"),
                    controller: _currentPasswordController,
                    obscureText: _passwordInvisibleOld,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_open),
                      hintText: 'Current password',
                      border: const OutlineInputBorder(),
                      labelText: 'Your password',
                      labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                      suffixIcon: IconButton(
                        key: const Key('lock1'),
                        onPressed: () {
                          setState(() {
                            _passwordInvisibleOld = !_passwordInvisibleOld;
                          });
                        },
                        icon: Icon(
                          _passwordInvisibleOld
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
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: MediaQuery.of(context).size.width < 600
                      ? 1.0
                      : 700 / MediaQuery.of(context).size.width,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width
                        : 700,
                    child: TextFormField(
                      key: const Key("newP"),
                      controller: _passwordController,
                      obscureText: _passwordInvisibleNew,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key_rounded),
                        //prefixIcon: const Icon(Icons.password),
                        hintText: 'New password',
                        border: const OutlineInputBorder(),
                        labelText: 'Your new password',
                        labelStyle:
                            const TextStyle(fontStyle: FontStyle.italic),
                        suffixIcon: IconButton(
                          key: const Key('lock2'),
                          onPressed: () {
                            setState(() {
                              _passwordInvisibleNew = !_passwordInvisibleNew;
                            });
                          },
                          icon: Icon(
                            _passwordInvisibleNew
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
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: MediaQuery.of(context).size.width < 600
                      ? 1.0
                      : 700 / MediaQuery.of(context).size.width,
                  child: TextFormField(
                    key: const Key("newP2"),
                    obscureText: _passwordInvisibleNew,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.vpn_key_rounded),
                      hintText: 'New password',
                      border: const OutlineInputBorder(),
                      labelText: 'Confirm new password',
                      labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                      suffixIcon: IconButton(
                        key: const Key('lock3'),
                        onPressed: () {
                          setState(() {
                            _passwordInvisibleNew = !_passwordInvisibleNew;
                          });
                        },
                        icon: Icon(
                          _passwordInvisibleNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: MediaQuery.of(context).size.width < 600
                      ? 1.0
                      : 200 / MediaQuery.of(context).size.width,
                  child: MyButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        //check if credentials present in db
                        await FirestoreCrud.getUserPwd(
                                username!, _currentPasswordController.text)
                            .then((values) async {
                          if (values!.docs.isNotEmpty) {
                            await changePassword();
                            // ignore: use_build_context_synchronously
                            _showSuccessDialog(context);
                          } else {
                            _showInvalidDialog(context);
                          }
                        });
                      }
                    },
                    text: "Save",
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Change'),
        content: const Text('Your password has been changed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInvalidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Change'),
        content: const Text('The password is not correct.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
