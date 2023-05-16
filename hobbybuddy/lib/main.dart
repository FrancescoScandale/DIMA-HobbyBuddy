import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hobbybuddy/firebase_options.dart';

String logo = 'assets/logo.png';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.ltr, // Replace with the appropriate text direction
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                logo, // Replace with your logo image path
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 16),
              // Buffering Icon
              CircularProgressIndicator(backgroundColor: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
