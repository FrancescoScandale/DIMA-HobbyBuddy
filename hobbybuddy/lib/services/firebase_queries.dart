import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/services/preferences.dart';

class FirebaseCrud {
  // CRUD
  static Stream<DocumentSnapshot<Object?>>? readSnapshot(
    CollectionReference collection,
    String id,
  ) {
    try {
      var document = collection.doc(id).snapshots();
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  static Future<DocumentSnapshot<Object?>?> readDoc(
    CollectionReference collection,
    String id,
  ) async {
    try {
      var document = await collection.doc(id).get();
      return document;
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return null;
  }

  static Future<void> updateDoc(
    CollectionReference collection,
    String id,
    String field,
    dynamic newValue,
  ) async {
    try {
      await collection.doc(id).update({
        field: newValue,
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<void> deleteDoc(
    CollectionReference collection,
    String id,
  ) async {
    try {
      await collection.doc(id).delete();
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  //OTHER QUERIES
  static Future<QuerySnapshot<Map<String, dynamic>>?> getUserPwd(String user, String pwd) async {
    QuerySnapshot<Map<String, dynamic>>? result;

    try {
      result = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .where("password", isEqualTo: pwd)
          .get();
      return result;
    } on FirebaseException catch (e) {
      print(e.message!);
      return null;
    }
  }

  //function used to retrieve user mentors and hobbies
  //data can be equal to 'hobbies' or 'mentors'
  static Future<List<String>> getUserData(String user, String data) async {
    List<String> result = [];

    try {
      result =
          await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: user).get().then((value) {
        String tmp = value.docs[0][data];
        result = tmp.split(',');
        return result; //result = [name0 surname0,name1 surname1]
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return result;
  }

  static Future<Map<String, bool>> getMentors(String hobby) async {
    Map<String, bool> result = {};
    List<String> favouriteMentors = [];

    try {
      favouriteMentors = Preferences.getMentors()!;
      result =
          await FirebaseFirestore.instance.collection("mentors").where("hobby", isEqualTo: hobby).get().then((values) {
        for (var doc in values.docs) {
          String tmp = doc['name'] + ' ' + doc['surname'];
          result[tmp] = favouriteMentors.contains(tmp);
        }

        return result; //result = [[name0 surname0, true],[name1 surname1, false]]
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return result;
  }

  //operation = 'add' or 'remove' based on the update to be done on the database
  static Future<void> updateFavouriteHobbies(String username, String hobby, String operation) async {
    List<String> hobbies = [];
    String id = '';

    hobbies = Preferences.getHobbies()!;
    if (hobbies.contains(hobby) && operation.compareTo('remove') == 0) {
      hobbies.remove(hobby);
    } else if (!hobbies.contains(hobby) && operation.compareTo('add') == 0) {
      hobbies.add(hobby);
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) => id = value.docs[0].id);
      await FirebaseFirestore.instance.collection("users").doc(id).update({'hobbies': hobbies.join(',')});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }
}
