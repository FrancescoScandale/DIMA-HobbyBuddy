import 'package:flutter/material.dart';

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
