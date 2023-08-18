import 'package:flutter/material.dart';
import 'package:hobbybuddy/widgets/button_icon.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(35);
  final String title;
  final List<Widget>? upRightActions;
  final ShapeBorder? shape;

  const MyAppBar({
    super.key,
    required this.title,
    this.upRightActions,
    this.shape,
  });
  static Widget acceptRequests(context) => MyIconButton(
        margin: const EdgeInsets.only(right: 40),
        onTap: () async {},
        icon:
            Icon(Icons.add_circle, color: Theme.of(context).primaryColorLight),
      );
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: upRightActions,
      scrolledUnderElevation: 0,
    );
  }
}
