import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

final firestore = FakeFirebaseFirestore();
void main() {
  group('Preferences', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      FirestoreCrud.init(firebaseInstance: firestore);
      SharedPreferences.setMockInitialValues({});
      await Preferences.init();
      await firestore.collection("users").add({
        "username": "marta",
        "hobbies": "Volleyball,Tennis",
        "mentors": "Emma,Luca",
        "email": "sfjbs@mail.com",
        "location": 'via poli 3',
      });
    });

    test('deleteData method should remove the specified data', () async {
      // Set up initial data
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('key', 'value');
        expect(prefs.getString('key'), 'value');
      });

      // Delete the data
      // Check if the data has been deleted
      SharedPreferences.getInstance().then((prefs) {
        Preferences.deleteData('key');
        expect(prefs.getString('key'), null);
      });
    });
    //bool
    test('getBool method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('key', true);
        expect(Preferences.getBool('key'), true);
      });
    });

    test('getBool method should return the default value', () {
      expect(Preferences.getBool('non_existent_key'), false);
    });

    test('setBool method should set the correct value', () async {
      await Preferences.setBool('key', false);
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getBool('key'), false);
      });
    });

    //username
    test('getUsername method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('username', 'marta');
        expect(Preferences.getUsername(), 'marta');
      });
    });

    test('getUsername method should return the default value', () {
      expect(Preferences.getUsername(), null);
    });

    test('getUsername method should set the correct value', () async {
      await Preferences.setUsername('marta');
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getString('username'), 'marta');
      });
    });

    //hobbies
    test('getHobbies method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('hobbies', ['Volleyball,Tennis']);
        expect(Preferences.getHobbies(), ['Volleyball,Tennis']);
      });
    });

    test('getHobbies method should return the default value', () {
      expect(Preferences.getHobbies(), null);
    });

    test('getUsername method should set the correct value', () async {
      await Preferences.setHobbies('marta');
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getStringList('hobbies'), ['Volleyball', 'Tennis']);
      });
    });

    //mentors
    test('getMentors method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('mentors', ['Emma, Luca']);
        expect(Preferences.getMentors(), ['Emma, Luca']);
      });
    });

    test('getMentors method should return the default value', () {
      expect(Preferences.getMentors(), null);
    });

    test('getUsername method should set the correct value', () async {
      await Preferences.setMentors('marta');
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getStringList('mentors'), ['Emma', 'Luca']);
      });
    });

    //email
    test('getEmail method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('email', 'sfjbs"@mail.com');
        expect(Preferences.getEmail(), 'sfjbs"@mail.com');
      });
    });

    test('getEmails method should return the default value', () {
      expect(Preferences.getEmail(), null);
    });

    test('getUsername method should set the correct value', () async {
      await Preferences.setEmail('marta');
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getString('email'), 'sfjbs@mail.com');
      });
    });

    //Location
    test('getlocation method should return the correct value', () {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('location', ['via poli 3']);
        expect(Preferences.getLocation(), ['via poli 3']);
      });
    });

    test('getEmails method should return the default value', () {
      expect(Preferences.getLocation(), null);
    });

    test('getUsername method should set the correct value', () async {
      await Preferences.setLocation('marta');
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.getStringList('location'), ['via poli 3']);
      });
    });
  });
}
