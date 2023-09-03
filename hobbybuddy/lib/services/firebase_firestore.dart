import 'dart:async';

import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobbybuddy/screens/homepage_mentor.dart';

import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

class FirestoreCrud {
  static late FirebaseFirestore fi; //firebase instance

  static void init({FirebaseFirestore? firebaseInstance}) {
    fi = firebaseInstance ?? FirebaseFirestore.instance;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>?> getUserPwd(
      String user, String pwd) async {
    QuerySnapshot<Map<String, dynamic>>? result;

    try {
      result = await fi
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

  static Future<void> addUserToFirestore(String email, String password,
      String username, String name, String surname, String location) async {
    // Add a new document with automatic ID to the "users" collection
    await fi.collection('users').add({
      'email': email,
      'friends': '',
      'hobbies': '',
      'location': location,
      'mentors': '',
      'password': password,
      'receivedReq': '',
      'sentReq': '',
      'username': username,
      'name': name,
      'surname': surname,
    });
  }

  ///function used to retrieve user mentors and hobbies
  ///data can be equal to 'hobbies' or 'mentors'
  static Future<List<String>> getUserData(String user, String data) async {
    List<String> result = [];

    try {
      result = await fi
          .collection("users")
          .where("username", isEqualTo: user)
          .get()
          .then((value) {
        String tmp = value.docs[0][data];
        if (tmp.isNotEmpty) {
          result = tmp.split(',');
        }
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
      result = await fi
          .collection("mentors")
          .where("hobby", isEqualTo: hobby)
          .get()
          .then((values) {
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
          await fi.collection("hobbies").doc("d11XvjCVnj8hKbXzIlDO").get();

      if (snapshot.exists) {
        String hobbiesData = snapshot.get("hobby");
        List<String> hobbyNames = hobbiesData.split(',');
        allHobbies.addAll(hobbyNames);
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
      final snapshot =
          await fi.collection("users").where("username", isEqualTo: user).get();
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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc = await fi
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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc =
          await fi.collection("users").where("username", isEqualTo: user).get();

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
      final userDoc = await fi
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
      final snapshot = await fi.collection("users").get();

      for (var doc in snapshot.docs) {
        String username = doc.get("username") as String;
        if (username != user && !result.contains(username)) {
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
  static Future<void> updateFavouriteHobbies(
      String username, String hobby, String operation) async {
    List<String> hobbies = [];
    String id = '';

    hobbies = Preferences.getHobbies()!;
    if (hobbies.contains(hobby) && operation.compareTo('remove') == 0) {
      hobbies.remove(hobby);
    } else if (!hobbies.contains(hobby) && operation.compareTo('add') == 0) {
      hobbies.add(hobby);
    }

    try {
      await fi
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) => id = value.docs[0].id);
      await fi
          .collection("users")
          .doc(id)
          .update({'hobbies': hobbies.join(',')});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<String> getHobby(String mentor) async {
    String hobby = '';
    try {
      await fi
          .collection("mentors")
          .where("name", isEqualTo: mentor.split(' ')[0])
          .where("surname", isEqualTo: mentor.split(' ')[1])
          .get()
          .then((value) => hobby = value.docs[0]['hobby']);
    } on FirebaseException catch (e) {
      print(e.message!);
    }

    return hobby;
  }

  ///operation = 'add' or 'remove' based on the update to be done on the database
  static Future<void> updateFavouriteMentors(
      String username, String mentor, String operation) async {
    List<String> mentors = [];
    String id = '';

    mentors = Preferences.getMentors()!;
    if (mentors.contains(mentor) && operation.compareTo('remove') == 0) {
      mentors.remove(mentor);
    } else if (!mentors.contains(mentor) && operation.compareTo('add') == 0) {
      mentors.add(mentor);
    }

    try {
      await fi
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) => id = value.docs[0].id);
      await fi
          .collection("users")
          .doc(id)
          .update({'mentors': mentors.join(',')});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<List<String>> getLocation(String username) async {
    List<String> coordinates;
    coordinates = await fi
        .collection('users')
        .where("username", isEqualTo: username)
        .get()
        .then((value) {
      return value.docs[0]['location'].toString().split(',');
    });
    return coordinates;
  }

  static Future<String> getEmail(String username) async {
    String email = await fi
        .collection('users')
        .where("username", isEqualTo: username)
        .get()
        .then((value) {
      return value.docs[0]['email'].toString();
    });

    return email;
  }

  static Future<void> updatePassword(String password, String username) async {
    try {
      fi
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          // Update the password field in each matching document
          doc.reference.update({'password': password});
        }
      });
      //({'password': password});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<void> updateUserInfo(
      String user, String name, String surname) async {
    try {
      fi
          .collection("users")
          .where("username", isEqualTo: user)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          // Update the password field in each matching document

          /*if (username.isNotEmpty) {
            doc.reference.update({'username': username});
            Preferences.setUsername(username);
          }*/
          if (name.isNotEmpty) {
            doc.reference.update({'name': name});
          }
          if (surname.isNotEmpty) {
            doc.reference.update({'surname': surname});
          }
        }
      });
      //({'password': password});
    } on FirebaseException catch (e) {
      print(e.message!);
    }
  }

  static Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot snapshot = await fi
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isEmpty;
  }

  static Future<List<String>> getUpcomingClasses(String mentor) async {
    List<String> result = [];
    String ts =
        DateTime.timestamp().toString().split('.')[0].replaceAll(' ', '_');

    try {
      result = await fi
          .collection("mentors")
          .where("name", isEqualTo: mentor.split(' ')[0])
          .where("surname", isEqualTo: mentor.split(' ')[1])
          .get()
          .then((value) {
        if (!value.docs[0].data().containsKey('classes')) {
          return [];
        }
        for (var item in value.docs[0]['classes']) {
          List<String> dates = item.split(';;')[2].split('/');
          String time = item.split(';;')[3];

          dates = dates.reversed.toList();
          String date = dates.join('-');

          String comparedTS = '${date}_$time';
          if (comparedTS.compareTo(ts) >= 0) {
            result.add(item);
          }
        }
        return result;
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }

    return result;
  }

  static Future<List<String>> getUserNameSurname(String username) async {
    List<String> result = [];
    try {
      result = await fi
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          result.add(doc['name']);
          result.add(doc[('surname')]);
        }
        return result;
      });
    } on FirebaseException catch (e) {
      print(e.message!);
    }

    return result;
  }

  /// getBytesFromAsset(), createMarker() and retrieveMarker() are used in maps.dart
  /// 3 functions are used instead of 1 just to keep it tidier
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData pic = await rootBundle.load(path).then((value) {
      img.Image image = img.decodePng(value.buffer.asUint8List())!;
      final resized = img.copyResize(image, width: 75);
      final resizedByteData = img.encodePng(resized);
      return ByteData.sublistView(resizedByteData);
    });

    return pic.buffer.asUint8List();
  }

  /// getBytesFromAsset(), createMarker() and retrieveMarker() are used in maps.dart
  /// 3 functions are used instead of 1 just to keep it tidier
  static Future<Marker> createMarker(BuildContext context, String id,
      double lat, double lng, String windowTitle, String windowMentor) async {
    Marker marker;
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/hobbies/$windowTitle.png', 50);

    marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
          title: windowTitle, //hobby name
          snippet: windowMentor, //mentor
          onTap: () {
            Widget newScreen = MentorPage(mentor: windowMentor);
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          }),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );

    return marker;
  }

  /// getBytesFromAsset(), createMarker() and retrieveMarker() are used in maps.dart
  /// 3 functions are used instead of 1 just to keep it tidier
  static Future<List<Marker>> retrieveMarkers(BuildContext context) async {
    List<Marker> markers = [];

    List<String> hobbies = Preferences.getHobbies()!;
    await fi.collection("markers").where('title', whereIn: hobbies).get().then(
      (value) async {
        for (var doc in value.docs) {
          Marker marker = await createMarker(
              context,
              doc.id,
              double.parse(doc["lat"]),
              double.parse(doc["lng"]),
              doc["title"],
              doc["mentor"]);
          markers.add(marker);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );

    return markers;
  }
}
