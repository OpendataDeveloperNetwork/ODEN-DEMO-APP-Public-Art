import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:oden_app/screens/components/markers.dart';
import 'package:oden_app/models/location.dart';

import 'package:http/http.dart' as http;

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

/// Represents the MapsPage.
class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => MapsPageState();
}

/// Represents the state of the MapsPage.
class MapsPageState extends State<MapsPage> {

  /// Manages clusters of map markers.
  late ClusterManager _manager;

  /// Encapsulates GoogleMapController for future use.
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  /// A set of markers to be displayed on the map.
  Set<Marker> _markers = {};

  /// Location to Google's headquarters.
  CameraPosition _kGooglePlex = const CameraPosition(target: LatLng(0, 0), zoom: 14.4746);

  /// List of raw JSON data from firebase.
  final List<dynamic> _rawJSON = [];

  /// List of PublicArt objects.
  final List<PublicArt> _publicArts = [];

  ClusterManager get manager => _manager;
  Set<Marker> get markers => _markers;
  List<PublicArt> get publicArts => _publicArts;
  List<dynamic> get rawJSON => _rawJSON;

  /// Updates the map markers; usually when an action is performed.
  void updateMarkers(Set<Marker> markers) {    
    setState(() {
      _markers = markers;
    });
  }

  void addMarker(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }

  void removeMarker(Marker marker) {
    setState(() {
      _markers.remove(marker);
    });
  }

  /// Creates and adds markers to the _markers object
  Future<void> _fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('PublicArts').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      var url = Uri.parse(data['link']);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        _rawJSON.addAll(jsonDecode(response.body));
        for (final data in _rawJSON) {
          PublicArt publicArt = jsonToPublicArt(data, data['link']);
          _publicArts.add(publicArt);
        }
      } else {
        // There was an error, handle it here
        print("OOps something happened somewhere.");
      }
    }
  }

  /// Calls setup methods and sets initial state.
  @override
  void initState() {
    setMaps(this);
    _manager = getClusterManager();
    super.initState();
    _setCurrentLocation();
    _fetchMarkers();
  }

  /// Gets the current location of the user.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Sets the camera location to the user's location.
  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        _kGooglePlex = CameraPosition(
            target: LatLng(pos.latitude, pos.longitude), zoom: 14.4746);
      });
    } catch (e) {
      debugPrint("Error");
    }
  }

  /// Creates and adds markers to the _markers object
  void _onMapCreated(GoogleMapController controller) {
    _controllerCompleter.complete(controller);
    setController(_controllerCompleter);
    _manager.setMapId(controller.mapId);
    addMarkers();
  }

  /// Builds the map_page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: profileAppBarWidget(context),
        body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _kGooglePlex.target.longitude == 0
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(51.072052, -114.076904),
                            zoom: 15,
                          ),
                          markers: _markers,
                          onCameraMove: _manager.onCameraMove,
                          onCameraIdle: _manager.updateMap,
                          onMapCreated: _onMapCreated,
                        ),
                ),
              ],
        )));
  }
}
