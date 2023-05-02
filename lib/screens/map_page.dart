import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class Data{
  void fetchData(){

  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Map<String, double> coordinates = {
    "lat": 49.125049,
    "long": -122.882897
  };


  final Map<String, Marker> _markers = {};

  // Creates and adds markers to the _markers object
  _onMapCreated(GoogleMapController controller) {
    _markers.clear();
    // Could add a for loop here to add multiple markers
    final marker = Marker(
      markerId: MarkerId("Public Art"),
      position: LatLng(coordinates["lat"]!, coordinates["long"]!),
      infoWindow: InfoWindow(
        title: "Public Art",
        snippet: "Mock Address",
      ),
  );

  setState(() {
  _markers.putIfAbsent("location", () => marker);
  });

}

  CameraPosition _kGooglePlex = const CameraPosition(target: LatLng(0, 0), zoom: 14.4746);

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        _kGooglePlex = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 14.4746);
        print("latlong  ${pos.latitude}  ${pos.longitude}");
      });
    } catch (e) {
      debugPrint("Error");
    }
  }


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

  final Completer<GoogleMapController> _controller = Completer<
      GoogleMapController>();


// Leave the appBar null, for now, I will be creating a appBar class for that! - Joshua //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: null,
        body: Column(
          children: [
            // Expanded(
            //   child: null
            // ),
            Expanded(
              child: _kGooglePlex.target.longitude == 0 ? const Center(child: CircularProgressIndicator()) : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: _onMapCreated,
                markers:_markers.values.toSet(),
              ),
            )
          ],
        ));
  }
}

