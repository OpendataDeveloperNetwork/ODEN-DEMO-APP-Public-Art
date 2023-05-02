import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';


// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class Data{

  void fetchData(){

  }
}

class Art{ 

  final double _lat;
  final double _long;
  final String _name;
  final String _description;
  final String _address;
  
  Art({
    required lat,
    required long,
    name = "Public Art",
    description = "This piece of art has no description",
    address = "This piece of art has no address",
  }) : _lat = lat,
       _long = long,
       _name = name,
       _description = description,
       _address = address;

  double get lat => _lat;
  double get long => _long;
  String get name => _name;
  String get description => _description;
  String get address => _address;

}

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {

  final List<Art> publicArt = [];

  final art1 = Art(
    lat: 41.906255000000002, 
    long: -87.699420000000003,
    name: "Interpreting Nature"
  );

  final art2 = Art(
    lat: 51.0486151,
    long: -114.0748777,
    name: "SWARM"
  );

  final art3 = Art(
    lat: 49.125049, 
    long: -122.882897
  );

  _MapsPageState() {
    publicArt.add(art1);
    publicArt.add(art2);
    publicArt.add(art3);
  }

  final Map<String, Marker> _markers = {};

  // Creates and adds markers to the _markers object
  _onMapCreated(GoogleMapController controller) {
    _markers.clear();
    // Could add a for loop here to add multiple markers
    for (final art in publicArt) {
      final marker = Marker(
        markerId: MarkerId(art.name),
        position: LatLng(art.lat, art.long),
        infoWindow: InfoWindow(
          title: art.name,
          snippet: art.description,
        ),
      );

      setState(() {
        _markers[art.name] = marker;
      });
    }

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

