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
}
