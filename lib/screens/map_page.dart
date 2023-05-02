import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class Data {
  Data() {
    fetchData();
  }

  Future<void> fetchData() async {
    var fire_base = await Firebase.initializeApp();
    var db = FirebaseFirestore.instance;
    db.collection("PublicArts").get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('$docSnapshot');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Data data = Data();

  CameraPosition _kGooglePlex = const CameraPosition(
      target: LatLng(0, 0), zoom: 14.4746);

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
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
              child: _kGooglePlex.target.longitude == 0 ? const Center(
                  child: CircularProgressIndicator()) : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            )
          ],
        ));
  }
}

