import 'package:flutter/material.dart';
import 'package:hobbybuddy/services/preferences.dart';

import 'package:hobbybuddy/widgets/app_bar.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouritesScreen> {
  List<String> hobbies = Preferences.getHobbies()!;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: MyAppBar(
          title: "Favourite Hobbies",
        ),
        body: Icon(Icons.favorite));
  }
}
