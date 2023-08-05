import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/models/user_model.dart';
import 'package:hobbybuddy/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'firebase_queries.dart';

import 'dart:io';

class FirebaseUser extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseUser(this._auth, this._firestore);

  // getters
  User? get user => _auth.currentUser;
  CollectionReference get userCollection =>
      _firestore.collection(UserModel.collectionName);

  Stream<UserModel> getCurrentUserStream() {
    return userCollection
        .doc(user!.uid)
        .snapshots()
        .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>));
  }

  // login
  Future<void> logInWithUsername({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      var usernameValidation =
          await userCollection.where('username', isEqualTo: username).get();

      if (usernameValidation.docs.isNotEmpty) {
        String email = (usernameValidation.docs[0].data()
            as Map<String, dynamic>)['email'];
        bool loggedIn = await loginWithEmail(
          email: email,
          password: password,
          context: context,
        );
        if (loggedIn) {
          showSnackBar(context, "Welcome, $username!");
        }
      } else {
        showSnackBar(context, "Username does not exist");
      }
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseCrud.readDoc(userCollection, _auth.currentUser!.uid);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
      print(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      print(e.message!);
    }
  }

  // signup
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String name,
    required String surname,
    required String profilePic,
    required BuildContext context,
  }) async {
    try {
      bool tmp;
      tmp = await usernameAlreadyExists(username: username);
      if (tmp) {
        showSnackBar(context, "Choose another username!");
        return false;
      }
      tmp = await emailAlreadyExists(email: email);
      if (tmp) {
        showSnackBar(context, "Choose another email!");
        return false;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // await sendEmailVerification(context);
      UserModel userEntity = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
        name: name,
        surname: surname,
        profilePic: profilePic,
      );
      Map<String, dynamic> userMap = userEntity.toMap();
      userMap["username_lower"] = username.toLowerCase();
      await userCollection.doc(userCredential.user!.uid).set(userMap);
      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }

  Future<bool> usernameAlreadyExists({required String username}) async {
    try {
      var usernameValidation =
          await userCollection.where('username', isEqualTo: username).get();
      return usernameValidation.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      print(e.message);
      return true;
    }
  }

  Future<bool> emailAlreadyExists({required String email}) async {
    try {
      var emailValidation =
          await userCollection.where('email', isEqualTo: email).get();
      return emailValidation.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      print(e.message);
      return true;
    }
  }

  // edit profile
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<bool> updateUserData({
    required String username,
    required String name,
    required String surname,
    required String email,
    required String profilePic,
    required bool updateProfilePic,
    required File? photo,
  }) async {
    try {
      var uid = _auth.currentUser!.uid;

      UserModel userEntity = UserModel(
        uid: uid,
        email: email,
        username: username,
        name: name,
        surname: surname,
        profilePic: profilePic,
      );

      Map<String, dynamic> userMap = userEntity.toMap();
      userMap["username_lower"] = username.toLowerCase();
      if (updateProfilePic) {
        String uid = _auth.currentUser!.uid;
        final destination = 'profile_pics/$uid';
        var ref = FirebaseStorage.instance.ref().child(destination);
        String profileUrl = "default";
        if (photo != null) {
          await ref.putFile(photo);
          profileUrl = await ref.getDownloadURL();
        }
        userMap["profilePic"] = profileUrl;
      }
      await userCollection.doc(uid).set(userMap);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return false;
  }

  Future<bool> reauthenticationCurrentUser({
    required BuildContext context,
    required String password,
  }) async {
    try {
      loginWithEmail(email: user!.email!, password: password, context: context);
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return false;
  }

  Future<bool> updateCurrentUserPassword({
    required BuildContext context,
    required String newPassword,
  }) async {
    try {
      await user?.updatePassword(newPassword);
      return true;
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
    return false;
  }

  // search
  Future<UserModel?> getUserData({required String uid}) async {
    try {
      var userDataDoc = await FirebaseCrud.readDoc(userCollection, uid);
      UserModel userDetails = UserModel.fromMap(
        userDataDoc?.data() as Map<String, dynamic>,
      );
      return userDetails;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  Future<List<UserModel>> getUsersData({required String pattern}) async {
    try {
      var users = await userCollection
          .orderBy('username_lower')
          .where('username_lower',
              isGreaterThanOrEqualTo: pattern.toLowerCase())
          .where('username_lower', isLessThan: '${pattern.toLowerCase()}z')
          .limit(10)
          .get();
      if (users.docs.isNotEmpty) {
        List<UserModel> usersData = users.docs
            .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
            .toList();
        return usersData;
      }
    } on FirebaseException catch (e) {
      //showSnackBar(context, e.message!);
      print(e.message);
    }
    return [];
  }

  Future<List<UserModel>> getUsersDataFromList({
    required List<String> uids,
  }) async {
    List<UserModel> usersData = [];
    await Future.wait(uids.map((uid) {
      return getUserData(uid: uid).then((value) {
        if (value != null) {
          return usersData.add(value);
        }
      });
    }));
    return usersData;
  }
}
