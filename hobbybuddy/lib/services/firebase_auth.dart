import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationCrud {
  static late FirebaseAuth auth; //firebase instance

  static void init({FirebaseAuth? authInstance}) {
    auth = authInstance ?? FirebaseAuth.instance;
  }
}
