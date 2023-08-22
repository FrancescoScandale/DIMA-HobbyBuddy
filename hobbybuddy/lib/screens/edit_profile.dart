import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  bool _isUsernameNotUnique = false;

  Future<void> updateUserToFirestore() async {
    String username = _usernameController.text;
    String name = _nameController.text;
    String surname = _surnameController.text;
    String? user = Preferences.getUsername();

    await FirebaseCrud.updateUserInfo(user!, username, name, surname);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Edit Profile"),
      body: Builder(
        builder: (BuildContext context) {
          return ResponsiveWrapper(
            child: Form(
              key: _formKey,
              child: Scrollbar(
                child: ListView(
                  controller: ScrollController(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.kHorizontalPadding,
                  ),
                  children: [
                    const SizedBox(height: 20),
                    const SizedBox(height: 40),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.face),
                        border: OutlineInputBorder(),
                        hintText: "Insert new username here",
                        labelText: 'Your new username',
                        labelStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onChanged: (username) async {},
                      /*validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },*/
                    ),
                    if (_isUsernameNotUnique)
                      const Text(
                        'This username is already taken. Please choose a different one.',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.shortcut_rounded),
                        border: OutlineInputBorder(),
                        hintText: "Insert new name here",
                        labelText: 'Your new name',
                        labelStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      /*validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },*/
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.shortcut_rounded),
                        //prefixIcon: const Icon(Icons.perm_identity),
                        border: OutlineInputBorder(),
                        hintText: "Insert new surname here",
                        labelText: 'Your new surname',
                        labelStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      /*validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Surname cannot be empty';
                        }
                        return null;
                      },*/
                    ),
                    const SizedBox(height: 50),
                    MyButton(
                        text: "Save",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String enteredUsername = _usernameController.text;
                            bool isUnique = await FirebaseCrud.isUsernameUnique(
                                enteredUsername);
                            // Username is unique, proceed
                            if (isUnique) {
                              await updateUserToFirestore();
                              setState(() {
                                _isUsernameNotUnique = false;
                              });
                              // ignore: use_build_context_synchronously
                              _showSuccessDialog(context);
                            } else {
                              // Username is not unique, show a warning
                              setState(() {
                                _isUsernameNotUnique = true;
                              });
                            }
                          }
                        }),
                    Container(height: AppLayout.kPaddingFromCreate),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Your profile has been updated successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              //Navigator.pop(context); // Go back
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
