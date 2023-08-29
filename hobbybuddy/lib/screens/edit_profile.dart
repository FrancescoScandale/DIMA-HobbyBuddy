import 'package:hobbybuddy/services/firebase_storage.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  //final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  // bool _isUsernameNotUnique = false;
  bool loading = false;

  final double _backgroundPadding = 250;
  late Image propic;
  late Image background;
  bool downloadUserPics = false;

  final ImagePicker picker = ImagePicker();
  late File _profileFile;
  late File _backgroundFile;
  bool _profilePicked = false;
  bool _backgroundPicked = false;

  Future<void> updateUserToFirestore() async {
    //String username = _usernameController.text;
    String name = _nameController.text;
    String surname = _surnameController.text;
    String? user = Preferences.getUsername();
    if (_profilePicked) {
      String profilePicPath = 'Users/$user/propic.jpg';
      // Convert the selected image file to Uint8List
      Uint8List profilePicData = await _profileFile.readAsBytes();
      await StorageCrud.getStorage()
          .ref(profilePicPath)
          .putData(profilePicData);
    }

    if (_backgroundPicked) {
      String backgroundPath = 'Users/$user/background.jpg';
      // Convert the selected image file to Uint8List
      Uint8List backgroundData = await _backgroundFile.readAsBytes();
      await StorageCrud.getStorage()
          .ref(backgroundPath)
          .putData(backgroundData);
    }

    await FirestoreCrud.updateUserInfo(user!, name, surname);

    Navigator.pop(context);
  }

  void getUserPics() async {
    String? username = Preferences.getUsername();
    Uint8List? propicData = await StorageCrud.getStorage()
        .ref()
        .child('Users/$username/propic.jpg')
        .getData();
    Uint8List? backgroundData = await StorageCrud.getStorage()
        .ref()
        .child('Users/$username/background.jpg')
        .getData();

    propic = Image.memory(propicData!);
    background = Image.memory(backgroundData!);

    setState(() {
      downloadUserPics = true;
    });
  }

  Future<void> pickImage(bool isProfilePic) async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfilePic) {
          _profileFile = File(pickedFile.path);
          _profilePicked = true;
        } else {
          _backgroundFile = File(pickedFile.path);
          _backgroundPicked = true;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserPics();
  }

  @override
  void dispose() {
    //_usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Edit Profile",
        automaticallyImplyLeading: loading ? false : true,
      ),
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
                          key: const Key('backgImage'),
                          height: _backgroundPadding,
                          width: MediaQuery.sizeOf(context).width,
                          child: (() {
                            if (_backgroundPicked) {
                              return Image.file(
                                _backgroundFile, // Display the selected profile picture
                                alignment: Alignment.center,
                                fit: BoxFit.fitHeight,
                              );
                            } else if (downloadUserPics) {
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
                            margin: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              child: _backgroundPicked
                                  ? Icon(
                                      Icons.close,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    )
                                  : Icon(
                                      Icons.photo_camera,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              onPressed: () {
                                if (_backgroundPicked) {
                                  setState(() {
                                    _backgroundPicked = false;
                                  });
                                } else {
                                  pickImage(false);
                                }
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
                                  if (_profilePicked) {
                                    return Image.file(
                                      _profileFile, // Display the selected profile picture
                                      width: AppLayout.kProfilePicRadiusLarge,
                                      height: AppLayout.kProfilePicRadiusLarge,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (downloadUserPics) {
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
                                    const EdgeInsets.only(top: 97, left: 60),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                  ),
                                  child: _profilePicked
                                      ? Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        )
                                      : Icon(
                                          Icons.photo_camera,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                  onPressed: () {
                                    if (_profilePicked) {
                                      setState(() {
                                        _profilePicked = false;
                                      });
                                    } else {
                                      pickImage(true);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    /* TextFormField(
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
                    const SizedBox(height: 20),*/
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
                        key: const Key('saveB'),
                        text: loading ? "Loading..." : "Save",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            //String enteredUsername = _usernameController.text;
                            //bool isUnique = await FirebaseCrud.isUsernameUnique(enteredUsername);
                            // Username is unique, proceed
                            // if (isUnique) {
                            setState(() {
                              loading = true;
                            });
                            await updateUserToFirestore();
                            /*setState(() {
                                _isUsernameNotUnique = false;
                              });
                              // ignore: use_build_context_synchronously
                              _showSuccessDialog(context);
                            } else {
                              // Username is not unique, show a warning
                              setState(() {
                                _isUsernameNotUnique = true;
                              });
                            }*/
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
