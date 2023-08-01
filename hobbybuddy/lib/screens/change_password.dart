import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/firebase_user.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordInvisibleOld = true;
  bool _passwordInvisibleNew = true;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
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
            child: ListView(
              controller: ScrollController(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.kHorizontalPadding,
              ),
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _passwordInvisibleOld,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_open),
                    hintText: 'Current password',
                    border: const OutlineInputBorder(),
                    labelText: 'Your password',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    suffixIcon: IconButton(
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _passwordInvisibleNew,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.vpn_key_rounded),
                    //prefixIcon: const Icon(Icons.password),
                    hintText: 'New password',
                    border: const OutlineInputBorder(),
                    labelText: 'Your new password',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    suffixIcon: IconButton(
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
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: _passwordInvisibleNew,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.vpn_key_rounded),
                    //prefixIcon: const Icon(Icons.password),
                    hintText: 'New password',
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm new password',
                    labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                    suffixIcon: IconButton(
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
                const SizedBox(height: 20),
                MyButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      bool reauthSuccess = await Provider.of<FirebaseUser>(
                              context,
                              listen: false)
                          .reauthenticationCurrentUser(
                              context: context,
                              password: _currentPasswordController.text);
                      if (reauthSuccess) {
                        // ignore: use_build_context_synchronously
                        await Provider.of<FirebaseUser>(context, listen: false)
                            .updateCurrentUserPassword(
                                context: context,
                                newPassword: _passwordController.text);
                      }
                    }
                  },
                  text: "Save",
                ),
                Container(height: AppLayout.kPaddingFromCreate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
