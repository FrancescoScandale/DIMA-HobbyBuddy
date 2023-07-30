import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String? text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        text ?? "",
        style: Theme.of(context).primaryTextTheme.titleMedium,
      ),
      duration: const Duration(seconds: 1, milliseconds: 500),
    ),
  );
}
