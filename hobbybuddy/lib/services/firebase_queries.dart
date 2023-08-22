import 'dart:async';

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

  ///function used to retrieve user mentors and hobbies
  ///data can be equal to 'hobbies' or 'mentors'
  static Future<List<String>> getUserData(String user, String data) async {
    List<String> result = [];

    try {
      result =
          await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: user).get().then((value) {
        String tmp = value.docs[0][data];
        result = tmp.split(',');
        return result; //result = [name0 surname0,name1 surname1] (for mentors)
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }
    return result;
  }

  /// retrieves all mentors and sets to true the ones that are favourite
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

  static Future<List<String>> getHobbies() async {
    List<String> allHobbies = [];

    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("hobbies").doc("d11XvjCVnj8hKbXzIlDO").get();

      if (snapshot.exists) {
        String hobbiesData = snapshot.get("hobby");
        List<String> hobbyNames = hobbiesData.split(',');
        allHobbies.addAll(hobbyNames);
        print('Check Favourite Hobby: $allHobbies');
      }
      return allHobbies;
    } catch (e) {
      print(e.toString());
      return []; // Return an empty list in case of error
    }
  }

  static Future<List<String>> getFriends(String user) async {
    List<String> result = [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String tmp = snapshot.docs[0].get("friends") as String;
        result = tmp.split(',');
      }
      return result;
    } catch (e) {
      print(e.toString());
      return []; // Return an empty list in case of error
    }
  }

  static Future<void> removeFriend(String user, String friendToRemove) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("friends") as String;
        List<String> friendList = tmp.split(',');
        friendList.remove(friendToRemove);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'friends': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> addFriend(String user, String friendToAdd) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("friends") as String;
        List<String> friendList = tmp.split(',');
        friendList.add(friendToAdd);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'friends': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> addReceivedRequest(
      String user, String friendToAdd) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("receivedReq") as String;
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];
        friendList.add(friendToAdd);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'receivedReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> removeReceivedRequest(
      String user, String friendToRemove) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("receivedReq");
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];

        friendList.remove(friendToRemove);

        String updatedFriendString = friendList.join(',');

        await userDoc.docs[0].reference
            .update({'receivedReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<String>> getReceivedRequest(String username) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String receivedRequestString =
            userDoc.docs[0].get("receivedReq") as String;
        List<String> receivedRequests = receivedRequestString.isNotEmpty
            ? receivedRequestString.split(',')
            : [];
        return receivedRequests;
      }
    } catch (e) {
      print(e.toString());
    }

    return [];
  }

  static Future<void> addSentRequest(String user, String friendToAdd) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("sentReq") as String;
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];
        friendList.add(friendToAdd);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'sentReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> removeSentRequest(
      String user, String friendToRemove) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: user)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String tmp = userDoc.docs[0].get("sentReq");
        List<String> friendList = tmp.isNotEmpty ? tmp.split(',') : [];
        friendList.remove(friendToRemove);
        String updatedFriendString = friendList.join(',');
        await userDoc.docs[0].reference
            .update({'sentReq': updatedFriendString});
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<String>> getSentRequest(String username) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String sentRequestString = userDoc.docs[0].get("sentReq") as String;
        List<String> sentRequests = sentRequestString.split(',');
        return sentRequests;
      }
    } catch (e) {
      print(e.toString());
    }

    return [];
  }

  static Future<List<String>> getAllOtherUsernames(String user) async {
    List<String> result = [];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("users").get();

      for (var doc in snapshot.docs) {
        String username = doc.get("username") as String;
        if (username != user) {
          result.add(username);
        }
      }

      List<String> userFriends = await getFriends(user);
      result.removeWhere((username) => userFriends.contains(username));
      return result;
    } catch (e) {
      print(e.toString());
      return []; // Return an empty list in case of error
    }
  }

  ///operation = 'add' or 'remove' based on the update to be done on the database
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

  ///operation = 'add' or 'remove' based on the update to be done on the database
  static Future<void> updateFavouriteMentors(String username, String mentor, String operation) async {
    List<String> mentors = [];
    String id = '';

    mentors = Preferences.getMentors()!;
    if (mentors.contains(mentor) && operation.compareTo('remove') == 0) {
      mentors.remove(mentor);
    } else if (!mentors.contains(mentor) && operation.compareTo('add') == 0) {
      mentors.add(mentor);
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) => id = value.docs[0].id);
      await FirebaseFirestore.instance.collection("users").doc(id).update({'mentors': mentors.join(',')});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<List<String>> getAddress(String username) async {
    List<String> coordinates;
    coordinates =
        await FirebaseFirestore.instance.collection('users').where("username", isEqualTo: username).get().then((value) {
      return value.docs[0]['location'].toString().split(',');
    });
    return coordinates;
  }

  static Future<String> getEmail(String username) async {
    String email =
        await FirebaseFirestore.instance.collection('users').where("username", isEqualTo: username).get().then((value) {
      return value.docs[0]['email'].toString();
    });

    return email;
  }
}
