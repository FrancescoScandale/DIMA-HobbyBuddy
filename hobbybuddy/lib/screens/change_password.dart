import 'package:firebase_auth/firebase_auth.dart';
import 'package:hobbybuddy/services/firebase_auth.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/preferences.dart';

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

  Future<bool> changePassword() async {
    User user = AuthenticationCrud.auth.currentUser!;
    String newPassword = _passwordController.text;

    try {
      //re-authenticate user to check current password inserted correctly
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
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
                        bool changed = await changePassword();
                        if (changed) {
                          // ignore: use_build_context_synchronously
                          _showSuccessDialog(context);
                        } else {
                          // ignore: use_build_context_synchronously
                          _showInvalidDialog(context);
                        }
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
