import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:hobbybuddy/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

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
              key: _formkey,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Surname cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    MyButton(
                        text: "Save",
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            showSnackBar(
                                context, "Your information has been updated!");
                            return;
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
}
