import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const MyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          padding:
              MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(15)),
          textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 18)),
        ),
        child: Text(text.toUpperCase()),
      ),
    );
  }
}
