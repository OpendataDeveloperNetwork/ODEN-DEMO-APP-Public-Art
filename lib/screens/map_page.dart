import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as location;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:oden_app/models/location.dart';

import './details.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  @override
  initState() {
    super.initState();
    _setCurrentLocation();
    _onMapCreated();
  }

  // Google maps controller
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  final Map<String, Marker> _markers = {};

  List publicArts = [];

  // Position of camera on map
  CameraPosition position = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 18.4746,
  );

  // Search box controller
  final myController = TextEditingController();

  // Creates and adds markers to the _markers object
  Future<List> _fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Categories').get();

    for (final doc in snapshot.docs) {
      var innerCols = doc.reference.collection("Items");
      QuerySnapshot innerSnapshot = await innerCols.get();

      for (final innerDoc in innerSnapshot.docs){
        PublicArt publicArt = await jsonToPublicArt(innerDoc);
        publicArts.add(publicArt);
      }
    }

    return publicArts;
  }

  // Creates a public art object
  jsonToPublicArt(publicArtJSON) async {
    double lat = double.parse(publicArtJSON["coordinates"]["latitude"].toString());
    double long = double.parse(publicArtJSON["coordinates"]["longitude"].toString());
    Position pos = await getCurrentLocation();
    double distanceBetweenLocations =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, long);

    return PublicArt(
        name: publicArtJSON["name"],
        latitude: lat,
        longitude: long,
        city: publicArtJSON["labels"]["cityCode"],
        country: publicArtJSON["labels"]["countryCode"],
        region: publicArtJSON["labels"]["regionCode"],
        distance: distanceBetweenLocations.round() / 1000);
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

  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        position = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 18.4746,
        );
      });
    } catch (e) {
      debugPrint("Error");
    }
  }

  // Creates and adds markers to the _markers object
  Future<void> _onMapCreated() async {
    publicArts = await _fetchMarkers();
    _markers.clear();
    for (final art in publicArts) {
      final marker = Marker(
        markerId: MarkerId(art.name),
        position: LatLng(art.latitude, art.longitude),
        infoWindow: InfoWindow(
          onTap: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DetailsPage(art)))
          },
          title: art.name,
          snippet: art.description,
        ),
      );

      setState(() {
        _markers[art.name] = marker;
      });
    }
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
      if(text.contains(",") || text.contains(" ")){
        var char = text.contains(",") ? "," : " ";
        List<String> searchField = text.split(char).map((e) => e.trim().toLowerCase()).toList();
        for (PublicArt art in publicArts) {
          if (art.name.toLowerCase() == searchField[0] && (art.city.toLowerCase() == searchField[1]
              || art.country.toLowerCase() == searchField[1]
              || art.region.toLowerCase() == searchField[1])) {
            found = true;
            position = CameraPosition(
              target: LatLng(art.latitude, art.longitude),
              zoom: 20.4746,
            );
          }
        }
      }else{
        for (PublicArt art in publicArts) {
          if (art.name.toLowerCase() == text) {
            found = true;
            position = CameraPosition(
              target: LatLng(art.latitude, art.longitude),
              zoom: 20.4746,
            );
          }
        }
      }

      if(!found){
        try{
          final List<location.Location> locations =
          await locationFromAddress(text);
          if (locations.isNotEmpty) {
            final location.Location loc = locations.first;
            position = CameraPosition(
              target: LatLng(loc.latitude, loc.longitude),
              zoom: 10.4746,
            );
          }
        }catch(e){
          // Invalid name
          _showDialog(context, "We couldn't find the location. Please try again");
        }
      }

      GoogleMapController gController = await _controller.future;
      gController.animateCamera(CameraUpdate.newCameraPosition(position));
      setState(() {});
    }

    myController.clear();
  }

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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: myController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  search();
                                },
                                color: Colors.white,
                                icon: const Icon(Icons.search),
                              ))
                        ],
                      )),
                ),
              ],
            ),
            Expanded(
                child: _markers.isNotEmpty
                    ? GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: position,
                        markers: _markers.values.toSet(),
                        onMapCreated: (GoogleMapController controller) {
                         _controller.complete(controller);
                        })
                    : const Center(child: CircularProgressIndicator()))
          ],
        )));
  }
}
