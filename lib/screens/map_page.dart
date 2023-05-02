import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _setCurrentLocation();
    _fetchMarkers();

  }
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Map<String, Marker> _markers = {};
  var publicArts = [];

  // Creates and adds markers to the _markers object
  Future<void> _fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('PublicArts').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      var url = Uri.parse(data['link']);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        publicArts.addAll(jsonDecode(response.body));
      } else {
        // There was an error, handle it here
        print("OOps something happened somewhere.");
      }
    }
  }

  CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(0, 0), zoom: 14.4746);

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
        _kGooglePlex = CameraPosition(
            target: LatLng(pos.latitude, pos.longitude), zoom: 14.4746);
      });
    } catch (e) {
      debugPrint("Error");
    }
  }

  // Creates and adds markers to the _markers object
  _onMapCreated(GoogleMapController controller) {
    _markers.clear();
    for (final art in publicArts) {
      final marker = Marker(
        // onTap: () => {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsPage()))
        // },
        markerId: MarkerId(art["art_id"]),
        position: LatLng(art["point"]["coordinates"][1], art["point"]["coordinates"][0]),
        infoWindow: InfoWindow(
          onTap: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DetailsPage()))
          },
          title: art["title"],
          snippet: art["short_desc"],
        ),
      );

      setState(() {
        _markers[art["art_id"]] = marker;
      });
    }
  }

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
              child: _kGooglePlex.target.longitude == 0
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                    ),
            )
          ],
        ));
  }
}
