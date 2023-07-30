import 'package:flutter/material.dart';

class ScreenTransition extends MaterialPageRoute {
  ScreenTransition({required super.builder});

  int duration = 150;
  Offset begin = const Offset(1, 0.0);
  Offset end = const Offset(0.0, 0.0);
  Curve curve = Curves.ease;

  @override
  Duration get transitionDuration => Duration(milliseconds: duration);

  @override
  Widget buildTransitions(context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween(
        begin: begin,
        end: end,
      )
          .chain(
            CurveTween(curve: curve),
          )
          .animate(animation),
      child: child,
    );
  }
}
