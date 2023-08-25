import 'package:flutter/material.dart';
import 'package:hobbybuddy/themes/layout.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(AppLayout.kAppBarHeight);
  final String title;
  final List<Widget>? upRightActions;
  final ShapeBorder? shape;
  final bool automaticallyImplyLeading;

  const MyAppBar({
    super.key,
    required this.title,
    this.upRightActions,
    this.shape,
    this.automaticallyImplyLeading = true
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
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
