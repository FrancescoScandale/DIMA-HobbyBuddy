import 'package:flutter/material.dart';

import 'package:hobbybuddy/widgets/app_bar.dart';

import 'package:hobbybuddy/widgets/button.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';

String logo = 'assets/logo.png';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Hobby Buddy"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsetsDirectional.fromSTEB(0, 20, 30, 0),
              child: FilledButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          content: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Positioned(
                                right: -15.0,
                                top: -15.0,
                                child: InkResponse(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide())),
                                      child: Center(
                                          child: Text("Find a Buddy",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Container(
                                          height: 50,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          "Search for a username",
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20),
                                                      border: InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      hintStyle: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: FilledButton(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 60,
                                          child: Center(
                                              child: Text(
                                            "Submit",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800),
                                          )),
                                        ),
                                        onPressed: () {},
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(8), // Adjust padding as needed
                  //backgroundColor: Color(0xffe65100), // Button background color
                ),
                child: const Icon(
                  Icons.person_add_alt_sharp,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
