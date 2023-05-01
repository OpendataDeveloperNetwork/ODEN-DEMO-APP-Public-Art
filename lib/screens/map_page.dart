import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class MapsPage extends StatelessWidget {
  MapsPage({super.key});

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  //Initial
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(49.1913, -122.8490),
    zoom: 10.4746,
  );

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
                child: GoogleMap(
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
