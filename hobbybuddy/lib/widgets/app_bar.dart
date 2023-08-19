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

  static Widget acceptRequests(
      BuildContext context, List<String>? receivedRequests) {
    int? requestCount = receivedRequests?.length;

    return Stack(
      children: [
        MyIconButton(
          margin: const EdgeInsets.only(right: 40),
          onTap: () async {},
          icon: Icon(
            Icons.person_add_alt_1,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        if (requestCount! > 0)
          Positioned(
            right: 30,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                    255, 165, 97, 9), //Color.fromARGB(255, 158, 111, 49),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$requestCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

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
      elevation: 0, // Remove the scrolledUnderElevation property
    );
  }
}
