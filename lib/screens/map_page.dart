import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as location;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationGiver;
import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:oden_app/main.dart';
import 'package:oden_app/models/firebase_user.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:oden_app/screens/components/markers.dart';

import '../models/auth.dart';

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
  /// Calls setup methods and sets initial state.
  @override
  void initState() {
    setMaps(this);
    _publicArts = db.getAllPublicArts();
    super.initState();
    _manager = getClusterManager();
    _setCurrentLocation();
    _displayMarkers();
    _monitorLocation();
  }

  // Google maps controller
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late GoogleMapController gController;

  LocationGiver.Location locationProvider = LocationGiver.Location();

  /// Manages clusters of map markers.
  late ClusterManager _manager;

  Set<Marker> _markers = {};

  /// List of PublicArt objects.
  List<PublicArt> _publicArts = [];

  // Position of camera on map
  CameraPosition position = const CameraPosition(
    target: LatLng(61.5240, 105.3188),
    zoom: 11.4746,
  );

  // Search box controller
  final myController = TextEditingController();

  ClusterManager get manager => _manager;

  Set<Marker> get markers => _markers;

  List<PublicArt> get publicArts => _publicArts;

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

  void _monitorLocation() {
    locationProvider.onLocationChanged
        .listen((LocationGiver.LocationData currentLocation) {
      checkArtworkProximity(currentLocation);
    });
  }

  void checkArtworkProximity(LocationGiver.LocationData currentLocation) {
    // Loop through each artwork in the list
    for (PublicArt art in publicArts) {
      // Calculate the distance between the user's location and the artwork

      double distance = Geolocator.distanceBetween(currentLocation.latitude!,
          currentLocation.longitude!, art.latitude, art.longitude);

      // If the distance is less than or equal to 100 meters, add the artwork to the database
      if (distance <= 100) {
        if (Auth().isLoggedIn) {
          _showDialog(
              context,
              "You are in close proximity to the public art \'${art.name}\'. Do you want to consider it visited ?",
              "Confirm",
              art);
        }
      }
    }
  }

  // Fetches the current location of user
  Future<LocationGiver.LocationData> getCurrentLocation() async {
    bool serviceEnabled;
    LocationGiver.PermissionStatus permissionGranted;

    serviceEnabled = await locationProvider.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationProvider.requestService();
      if (!serviceEnabled) {
        return Future.error("Services are not enabled");
      }
    }

    permissionGranted = await locationProvider.hasPermission();
    if (permissionGranted == LocationGiver.PermissionStatus.denied) {
      permissionGranted = await locationProvider.requestPermission();
      if (permissionGranted != LocationGiver.PermissionStatus.granted) {
        return Future.error("Permission not granted");
      }
    }
    Future<LocationGiver.LocationData> loc =
        LocationGiver.Location().getLocation();

    return await loc;
  }

  /// Sets the camera location to the user's location.
  Future<void> _setCurrentLocation() async {
    try {
      LocationGiver.LocationData pos = await getCurrentLocation();
      double? lat = pos.latitude;
      double? long = pos.longitude;

      if (lat != null && long != null) {
        position = CameraPosition(
          target: LatLng(pos.latitude!, pos.longitude!),
          zoom: 15.4746,
        );
        getController().animateCamera(CameraUpdate.newCameraPosition(position));
        setState(() {});
      } else {
        _showDialog(
            context, "We couldn't fetch your current location", "Error", null);
      }
    } catch (e) {
      debugPrint("Error, ${e.toString()}");
    }
  }

  // Creates and adds markers to the _markers object
  _displayMarkers() async {
    await addMarkers();
  }

  Future<void> _OnMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    await setController(_controller);
    _manager.setMapId(getController().mapId);
  }

  // Displays a dialogue box
  void _showDialog(BuildContext context, String message, String title,
      PublicArt? art) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: !title.startsWith("Error")
              ? <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ]
              : [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => FirebaseUserRepo()
                          .addPublicArtToVisits(Auth().uid, art!),
                      child: const Text('Confirm'))
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
          _showDialog(context,
              "We couldn't find the location. Please try again", "Error", null);
        }
      }

      getController().animateCamera(CameraUpdate.newCameraPosition(position));
      setState(() {});
    }

    myController.clear();
  }

  void _onCameraMove(CameraPosition position) {
    changeMarkers(position, markers);
    _manager.onCameraMove(position);
  }

  Container _buildMap() {
    return Container(
        height: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: position,
                markers: _markers,
                onCameraMove: _onCameraMove,
                onCameraIdle: _manager.updateMap,
                onMapCreated: (controller) => _OnMapCreated(controller)),
            Positioned(
              bottom: 30.0,
              left: 16.0,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: _setCurrentLocation,
                child: const Icon(Icons.my_location_sharp),
              ),
            )
          ],
        ));
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
