import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobbybuddy/services/firebase_firestore.dart';
import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/services/preferences.dart';

const double startingZoom = 17;

class MapsScreen extends StatelessWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        title: 'Buddy Finder',
      ),
      body: MapClass(),
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
  List<Marker> markers = [];
  late LatLng location;
  late CameraPosition _goHome;
  bool loaded = false;
  late GoogleMapController mapController;
  //used to update the camera position
  //useful because the map lags and the button uses this to go back to the initial position

  @override
  void initState() {
    getLocation();
    getMarkers();
    super.initState();
  }

  void getLocation() async {
    List<String> result;
    result = Preferences.getLocation()!;

    location = LatLng(double.parse(result[0]), double.parse(result[1]));

    _goHome = CameraPosition(
      target: location,
      zoom: startingZoom,
    );

    setState(() {
      loaded = true;
    });
  }

  Future<void> goHomeFunction() async {
    await mapController.animateCamera(CameraUpdate.newCameraPosition(_goHome));
  }

  void getMarkers() async {
    markers = await FirestoreCrud.retrieveMarkers(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loaded
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: location, zoom: startingZoom),
                  onMapCreated: (GoogleMapController controller) async {
                    String style = await DefaultAssetBundle.of(context)
                        .loadString('assets/map_style.json');
                    controller.setMapStyle(style);
                    mapController = controller;
                  },
                  markers: markers.toSet(),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsetsDirectional.only(bottom: 100),
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton.extended(
                          heroTag: 'reloadButton',
                          onPressed: getMarkers,
                          label: const Text('Reload Hobbies')),
                      FloatingActionButton.extended(
                          heroTag: 'homeButton',
                          onPressed: goHomeFunction,
                          label: const Text('Go Back Home')),
                    ],
                  ),
                )
              ],
            )
          : Container(),
    );
  }
}
