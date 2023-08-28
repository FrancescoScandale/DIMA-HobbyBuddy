import 'package:firebase_storage/firebase_storage.dart';

class StorageCrud {
  static late FirebaseStorage fs;

  static void init({FirebaseStorage? storageInstance}) {
    fs = storageInstance ?? FirebaseStorage.instance;
  }

  static FirebaseStorage getStorage() {
    return fs;
  }
}
