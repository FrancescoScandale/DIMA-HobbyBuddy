import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const MyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          padding: padding ?? const EdgeInsets.all(5),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: icon,
        ),
      ),
    );
  }
}
