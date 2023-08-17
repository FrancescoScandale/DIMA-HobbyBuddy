import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:hobbybuddy/services/light_dark_manager.dart';
import 'package:provider/provider.dart';
import 'package:hobbybuddy/themes/layout.dart';
import 'package:hobbybuddy/services/preferences.dart';

import 'package:hobbybuddy/widgets/app_bar.dart';

import 'package:hobbybuddy/widgets/screen_transition.dart';
import 'package:hobbybuddy/widgets/container_shadow.dart';

import 'package:hobbybuddy/screens/change_password.dart';
import 'package:hobbybuddy/screens/edit_profile.dart';
import 'package:hobbybuddy/main.dart';

String logo = 'assets/logo.png';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({Key? key}) : super(key: key);

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "My friends",
      ),
      body: ListView(),
    );
  }
}
