import 'dart:async';
import 'package:objectbox/objectbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as location;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:oden_app/objectbox.g.dart';
import 'package:oden_app/screens/components/markers.dart';
import 'package:oden_app/models/store.dart';

import '../main.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

/// Represents the MapsPage.
class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // Google maps controller
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController gController;

  /// Manages clusters of map markers.
  late ClusterManager _manager;

  Set<Marker> _markers = {};

  /// List of PublicArt objects.
  late List<PublicArt> _publicArts;

  // Position of camera on map
  CameraPosition position = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 18.4746,
  );

  // Search box controller
  final myController = TextEditingController();

  ClusterManager get manager => _manager;

  Set<Marker> get markers => _markers;

  List<PublicArt> get publicArts => _publicArts;

  /// Calls setup methods and sets initial state.
  @override
  void initState() {
    setMaps(this);
    _publicArts = db.getAllPublicArts();
    print(_publicArts.length);
    _manager = getClusterManager();
    super.initState();
    _displayMarkers();
    _setCurrentLocation();
  }

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

  // Fetches the current location of user
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
  void _setCurrentLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        position = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 18.4746,
        );
      });
    } catch (e) {
      debugPrint("Error, ${e.toString()}");
    }
  }

  // Creates and adds markers to the _markers object
  Future<void> _displayMarkers() async {
    await addMarkers();
  }

  Future<void> _OnMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    await setController(_controller);
    _manager.setMapId(getController().mapId);
  }

  // Displays a dialogue box
  void _showDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Handles search
  Future<void> search() async {
    var text = myController.text.trim().toLowerCase();
    bool found = false;

    if (text.isNotEmpty) {
      if (text.contains(",")) {
        List<String> searchField =
            text.split(",").map((e) => e.trim().toLowerCase()).toList();
        for (PublicArt art in _publicArts) {
          if (art.name.toLowerCase() == searchField[0] &&
              (art.city.toLowerCase() == searchField[1] ||
                  art.country.toLowerCase() == searchField[1] ||
                  art.region.toLowerCase() == searchField[1])) {
            found = true;
            position = CameraPosition(
              target: LatLng(art.latitude, art.longitude),
              zoom: 20.4746,
            );
          }
        }
      } else {
        for (PublicArt art in _publicArts) {
          if (art.name.toLowerCase() == text) {
            found = true;
            position = CameraPosition(
              target: LatLng(art.latitude, art.longitude),
              zoom: 20.4746,
            );
          }
        }
      }

      if (!found) {
        try {
          final List<location.Location> locations =
              await locationFromAddress(text);
          if (locations.isNotEmpty) {
            final location.Location loc = locations.first;
            position = CameraPosition(
              target: LatLng(loc.latitude, loc.longitude),
              zoom: 10.4746,
            );
          }
        } catch (e) {
          // Invalid name
          _showDialog(
              context, "We couldn't find the location. Please try again");
        }
      }

      getController().animateCamera(CameraUpdate.newCameraPosition(position));
      setState(() {});
    }

    myController.clear();
  }

  Container _buildMap() {
    return Container(
        height: double.infinity,
        child: position.target.longitude != 0
            ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: position,
                markers: _markers,
                onCameraMove: _manager.onCameraMove,
                onCameraIdle: _manager.updateMap,
                onMapCreated: (controller) => _OnMapCreated(controller))
            : const Center(child: CircularProgressIndicator()));
  }

  Container _buildSearchBar() {
    return Container(
        height: 50,
        margin: const EdgeInsets.fromLTRB(40, 30, 40, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF000080)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const BackButton(),
            Expanded(
              child: TextField(
                controller: myController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: profileAppBarWidget(context, false),
        body: Stack(
          children: [
            _buildMap(),
            _buildSearchBar(),
          ],
        ));
  }
}
