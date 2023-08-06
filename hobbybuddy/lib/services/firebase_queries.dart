import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

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
        return result;
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return result;
  }

  static Future<List<String>> getMentors(String hobby) async {
    List<String> result = [];

    try {
      result =
          await FirebaseFirestore.instance.collection("mentors").where("hobby", isEqualTo: hobby).get().then((values) {
        for (var doc in values.docs) {
          String tmp = doc['name'] + ' ' + doc['surname'];
          result.add(tmp);
        }
        return result;
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return result;
  }
}
