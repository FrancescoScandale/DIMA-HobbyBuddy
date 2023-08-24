import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:flutter/src/material/theme_data.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({Key? key, required this.mentor, required this.courseID}) : super(key: key);

  final String mentor;
  final String courseID; //in our case it's the date

  @override
  State<CoursesPage> createState() => _CoursesPageState(mentor, courseID);
}

class _CoursesPageState extends State<CoursesPage> {
  late String _mentor;
  late String _courseID;
  String text = '';
  late Widget returned;
  bool textFinished = false;

  _CoursesPageState(String mentor, String courseID) {
    _mentor = mentor;
    _courseID = courseID;
  }

  Widget setupText() {
    List<String> lines = text.split('\n');
    List<Widget> formattedContent = [];

    List<String> currentList = [];
    for (String line in lines) {
      if (line.startsWith('-') || line.startsWith('*') || line.startsWith('•')) {
        currentList.add(line.substring(1).trim());
      } else {
        if (currentList.isNotEmpty) {
          formattedContent.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentList
                  .map((item) => ListTile(
                      contentPadding: EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      dense: true,
                      visualDensity: VisualDensity(vertical: -4),
                      title: Text(
                        '-$item',
                        style: TextStyle(fontSize: 15),
                      )))
                  .toList(),
            ),
          );
          currentList.clear();
        }
        formattedContent.add(Text(
          line,
          style: TextStyle(fontSize: 15),
        ));
      }
    }

    if (currentList.isNotEmpty) {
      formattedContent.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: currentList
              .map((item) => ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -4),
                  title: Text('-$item', style: TextStyle(fontSize: 15))))
              .toList(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formattedContent,
      ),
    );
  }

  void retrieveData() async {
    Uint8List? result =
        await FirebaseStorage.instance.ref().child('Mentors/$_mentor/courses/$_courseID/text.txt').getData();
    text = utf8.decode(result!);
    returned = setupText();
    setState(() {
      textFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    retrieveData();
    return Scaffold(
        appBar: const MyAppBar(
          title: 'Course Page',
        ),
        body: ListView(
          children: [
            textFinished 
            ? Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: AppLayout.kModalHorizontalPadding/2),
              child: returned)
            : Container(),
          ],
        ));
  }
}
