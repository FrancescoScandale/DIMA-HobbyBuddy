import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/button.dart';

import '../widgets/app_bar.dart';

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

  _AddMilestoneState(String user) {
    _username = user;
  }

  @override
  void dispose() {
    caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: "Add New Milestone",
        ),
        body: ListView(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppLayout.kHorizontalPadding),
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
                  if (value == null || value.isEmpty) {
                    return 'Caption not entered';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(), //add picture from camera
            const SizedBox(height: 50),
            MyButton(
                text: 'Upload Milestone',
                onPressed: () {},
              ),
          ],
        ));
  }
}


//TODO: used for the uploads
// DateTime timestamp = DateTime.timestamp();
// String ts = timestamp.toString().split('.')[0].replaceAll(' ', '_');
    // print('timestamp -> $timestamp');
    // print('used timestamp -> $ts');