import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:oden_app/components/profile_button_app_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oden_app/screens/details.dart';
import 'package:oden_app/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {

  /// Manages clusters of map markers.
  late ClusterManager _manager;

  /// Encapsulates GoogleMapController for future use.
  final Completer<GoogleMapController> _controller = Completer();

  GoogleMapController? controller;

  Set<Marker> _markers = {};

  CameraPosition _kGooglePlex =
      const CameraPosition(target: LatLng(0, 0), zoom: 14.4746);

  var rawJSON = [];

  final List<PublicArt> publicArts = [];

  @override
  void initState() {
    // TODO: implement initState
    _manager = _initClusterManager();
    super.initState();
    _setCurrentLocation();
    _fetchMarkers();
  }

  ClusterManager<PublicArt> _initClusterManager() {
    return ClusterManager<PublicArt>(
      publicArts,
      _updateMarkers,
      markerBuilder: _markerBuilder,
    );
  }

  void _updateMarkers(Set<Marker> markers) async {
    print('Updated ${markers.length} markers');
    double zoom = await _getZoom();
    print("<---------- Zoom: $zoom ---------->");
    setState(() {
      // if (zoom >= maxClusterZoom) {
      //   _addMarkers();
      // } else {
      //   _markers = markers;
      // } 
      _markers = markers;
    });
  }

  Future<Marker> Function(Cluster<PublicArt>) get _markerBuilder => (cluster) async {
    double cameraZoom = await _getZoom();
    if (cluster.isMultiple) {
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        onTap: () {
          controller!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: cluster.location,
                zoom: cameraZoom,
              ),
            ),
          );
        },
        icon: await _getClusterBitmap(_getClusterSize(cluster.count),
                text: cluster.count.toString()),
      );
    }
    var art = cluster.items.first;
    return Marker(
      markerId: MarkerId(art.name),
      position: art.location,
      infoWindow: InfoWindow(
          onTap: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DetailsPage()))
          },
          title: art.name,
          snippet: art.description,
        )
    );
  };

  int _getClusterSize(clusterCount) {
    double baseSize = 100;
    double scaleFactor = 0.5;
    final double exponent = 1.1;
    final size = (baseSize + (pow(clusterCount, exponent) * scaleFactor)).toInt();
    print("<---------- Cluster Count: $clusterCount ---------->");
    print("<---------- Size of Cluster: $size ---------->");
    return size;
  }

  static Future<BitmapDescriptor> _getClusterBitmap(int size,
      {String? text}) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.red;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 2.5,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    } else {
      return BitmapDescriptor.defaultMarker;
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<double> _getZoom() async {
    final double zoom = await controller!.getZoomLevel();
    return zoom;
  }

  void _setController() async {
    controller = await _controller.future;
  }

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

  void _addMarkers() {
    _markers.clear();
    for (final art in publicArts) {
      final marker = Marker(
        markerId: MarkerId(art.name),
        position: LatLng(art.latitude, art.longitude),
        infoWindow: InfoWindow(
          onTap: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DetailsPage()))
          },
          title: art.name,
          snippet: art.description,
        ),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  // Creates and adds markers to the _markers object
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _setController();
    _manager.setMapId(controller.mapId);
    _addMarkers();
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
