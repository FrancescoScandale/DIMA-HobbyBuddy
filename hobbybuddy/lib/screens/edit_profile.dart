import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/services/firebase_queries.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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

  final double _backgroundPadding = 250;
  late Image propic;
  late Image background;
  bool downloadUserPics = false;

  final ImagePicker picker = ImagePicker();
  late File _imageFile;
  bool _imagePicked = false;

  Future<void> updateUserToFirestore() async {
    String username = _usernameController.text;
    String name = _nameController.text;
    String surname = _surnameController.text;
    String? user = Preferences.getUsername();

    await FirebaseCrud.updateUserInfo(user!, username, name, surname);
  }

  void getUserPics() async {
    String? username = Preferences.getUsername();
    Uint8List? propicData = await FirebaseStorage.instance
        .ref()
        .child('Users/$username/propic.jpg')
        .getData();
    Uint8List? backgroundData = await FirebaseStorage.instance
        .ref()
        .child('Users/$username/background.jpg')
        .getData();

    propic = Image.memory(propicData!);
    background = Image.memory(backgroundData!);

    setState(() {
      downloadUserPics = true;
    });
  }

  Future pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePicked = true;
      });
    }

    return;
  }

  @override
  void initState() {
    super.initState();
    getUserPics();
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
                    const SizedBox(height: 5),
                    Stack(
                      children: [
                        SizedBox(
                          height: _backgroundPadding,
                          width: MediaQuery.sizeOf(context).width,
                          child: (() {
                            if (downloadUserPics) {
                              return Image(
                                image: background.image,
                                alignment: Alignment.center,
                                fit: BoxFit.fitHeight,
                              );
                            } else {
                              return Container();
                            }
                          })(),
                        ),
                        Positioned(
                          bottom: 75,
                          right: -8,
                          child: Container(
                            margin: const EdgeInsets.all(
                                16), // Adjust the margin as needed
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () {
                                // Add your close icon functionality here
                              },
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 220, 0, 0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppLayout.kProfilePicRadiusLarge),
                                child: (() {
                                  if (downloadUserPics) {
                                    return Image(
                                      image: propic.image,
                                      width: AppLayout.kProfilePicRadiusLarge,
                                      height: AppLayout.kProfilePicRadiusLarge,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Container();
                                  }
                                })(),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 97, left: 60), //
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () {
                                    // Add your close icon functionality here
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
