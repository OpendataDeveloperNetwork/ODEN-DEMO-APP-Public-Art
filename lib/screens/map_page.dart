import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './details.dart';
import 'package:oden_app/models/location.dart';

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

  var rawJSON = [];
  final List<PublicArt> publicArts = [];

  // Creates and adds markers to the _markers object
  Future<void> _fetchMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('PublicArts').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      var url = Uri.parse(data['link']);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        rawJSON.addAll(jsonDecode(response.body));
        for (final data in rawJSON) {
          PublicArt publicArt = jsonToPublicArt(data, data['link']);
          publicArts.add(publicArt);
        }
      } else {
        // There was an error, handle it here
        print("OOps something happened somewhere.");
      }
    }
  }

  PublicArt jsonToPublicArt(publicArtJSON, dataLink) {
    return PublicArt(
        name: publicArtJSON["title"],
        latitude: publicArtJSON["point"]["coordinates"][1],
        longitude: publicArtJSON["point"]["coordinates"][0],
        description: publicArtJSON["short_desc"],
        link: dataLink);
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
      print("<--------------------------------------->");
      print(art);
      final marker = Marker(
        // onTap: () => {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsPage()))
        // },
        markerId: MarkerId(art.name),
        position: LatLng(art.latitude, art.longitude),
        infoWindow: InfoWindow(
          onTap: () => {
            Navigator.pushNamed(context, '/details') //arguments: art)
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

  @override
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
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: _onMapCreated,
                      markers: _markers.values.toSet(),
                    ),
            )
          ],
        )));
  }
}
