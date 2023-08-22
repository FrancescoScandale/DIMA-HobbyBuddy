import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/button.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hobbybuddy/widgets/app_bar.dart';

class AddMilestone extends StatefulWidget {
  const AddMilestone({Key? key, required this.user}) : super(key: key);

  final String user;

  @override
  State<AddMilestone> createState() => _AddMilestoneState(user);
}

class _AddMilestoneState extends State<AddMilestone> {
  late String _username;
  final _formKey = GlobalKey<FormState>();
  TextEditingController caption = TextEditingController();
  final ImagePicker picker = ImagePicker();
  late File _imageFile;
  bool _imagePicked = false;
  bool _notUploaded = true;

  _AddMilestoneState(String user) {
    _username = user;
  }

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePicked = true;
      });
    }

    return;
  }

  void uploadMilestone() async {
    String ts = DateTime.timestamp().toString().split('.')[0].replaceAll(' ', '_');

    FirebaseStorage.instance.ref().child('Users/$_username/milestones/$ts/caption.txt').putString(caption.text);
    await FirebaseStorage.instance.ref().child('Users/$_username/milestones/$ts/pic.jpg').putFile(_imageFile);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: "Add New Milestone",
        ),
        body: ListView(
          //padding: const EdgeInsetsDirectional.symmetric(horizontal: AppLayout.kHorizontalPadding),
          padding:
              const EdgeInsetsDirectional.fromSTEB(AppLayout.kHorizontalPadding, 0, AppLayout.kHorizontalPadding, 100),
          children: [
            Container(
              height: AppLayout.kVerticalPadding,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: caption,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                  labelText: 'Caption',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                    return 'You missed to enter the caption...';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            _imagePicked
                ? Image.file(
                    _imageFile,
                  )
                : Container(),
            const SizedBox(height: 10),
            Container(
                margin: EdgeInsetsDirectional.symmetric(horizontal: 150),
                child: ElevatedButton(
                    onPressed: () => pickImage(),
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(5)),
                    ),
                    child: const Icon(Icons.add_a_photo))),
            const SizedBox(height: 30),
            _notUploaded
                ? MyButton(
                    text: 'Upload Milestone',
                    onPressed: () {
                      //if (_formKey.currentState!.validate()) {
                      if (caption.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Need to insert a caption...")),
                        );
                      } else if (!_imagePicked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Need to upload an image...")),
                        );
                      } else {
                        setState(() {
                          _notUploaded = false;
                        });
                        uploadMilestone();
                      }
                      //}
                    },
                  )
                : MyButton(
                    text: 'Uploading...',
                    onPressed: () {},
                  ),
          ],
        ));
  }
}
