import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybuddy/screens/homepage_mentor.dart';
import 'package:hobbybuddy/services/preferences.dart';
import 'package:hobbybuddy/widgets/screen_transition.dart';

const LatLng startingLocation = LatLng(45.464037, 9.190403); //location taken from 45.464037, 9.190403
const double startingZoom = 17;

class MapsScreen extends StatelessWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Buddy Finder';

    return Scaffold(
      //debugShowCheckedModeBanner: false,

      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: const MapClass(),
    );
  }
}

class MapClass extends StatefulWidget {
  const MapClass({Key? key}) : super(key: key);

  @override
  MapState createState() {
    return MapState();
  }
}

class MapState extends State<MapClass> {
  List<Marker> mapMarkers = [];
  late GoogleMapController mapController; //used to update the camera position
  //useful because the map lags and the button uses this to go back to the initial position

  static const CameraPosition _goHome = CameraPosition(
    target: startingLocation,
    zoom: startingZoom,
  );

  Future<void> _goHomeFunction() async {
    await mapController.animateCamera(CameraUpdate.newCameraPosition(_goHome));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void createMarker(String id, double lat, double lng, String windowTitle, String windowMentor) async {
    Marker marker;

    final Uint8List markerIcon = await getBytesFromAsset('assets/hobbies/$windowTitle.png', 50);

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
          }
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );

    setState(() {
      mapMarkers.add(marker);
    });
    return;
  }

  Future<void> retrieveMarkers() async {
    List<String> hobbies = Preferences.getHobbies()!;
    await FirebaseFirestore.instance.collection("markers").where('title', whereIn: hobbies).get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          createMarker(doc.id, double.parse(doc["lat"]), double.parse(doc["lng"]), doc["title"], doc["mentor"]);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: startingLocation, zoom: startingZoom),
        onMapCreated: (GoogleMapController controller) async {
          String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
          controller.setMapStyle(style);
          mapController = controller;
          retrieveMarkers();
        },
        markers: mapMarkers.toSet(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          onPressed: _goHomeFunction,
          label: const Text('Go back home'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
