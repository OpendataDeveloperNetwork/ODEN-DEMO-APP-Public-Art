import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oden_app/models/location.dart';
import 'package:oden_app/screens/details.dart';

/// Constant values for the cluster icon.
const double baseSize = 100;
const double scaleFactor = 0.5;
const double exponent = 1.1;
const int alpha1 = 200;
const int alpha2 = 175;
const int offsetSizeDivisor = 2;
const double innerCircleRadiusDivisor = 2.0;
const double outerCircleRadiusDivisor = 2.2;
const double fontSizeDivisor = 2.5;

/// Max zoom level for clustering.
const double maxClusterZoom = 16.0;

/// Constant values for zoom
const zoomFactor = 2.0;

late GoogleMapController controller;
late var mapsPage;

/// Sets the mapsPage object.
void setMaps(mapsPageState) => mapsPage = mapsPageState;

/// Initializes the cluster manager.
ClusterManager<PublicArt> getClusterManager() {
  return ClusterManager<PublicArt>(
    mapsPage.publicArts,
    mapsPage.updateMarkers,
    markerBuilder: _markerBuilder,
    stopClusteringZoom: maxClusterZoom,
  );
}

/// Gets the current zoom level of the map.
Future<double> getZoom() async => await controller.getZoomLevel();

/// Sets the map controller once it has been retrieved from the completer.
Future<void> setController(
    Completer<GoogleMapController> controllerCompleter) async {
  controller = await controllerCompleter.future;
}

GoogleMapController getController() {
  return controller;
}

/// Constructs the markers based on whether they are a cluster or not.
Future<Marker> Function(Cluster<PublicArt>) get _markerBuilder =>
    (cluster) async {
      if (cluster.isMultiple) {
        double newZoom = (await getZoom()) + zoomFactor;
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: cluster.location, zoom: newZoom),
              ),
            );
          },
          infoWindow: InfoWindow(
            title: cluster.count.toString(),
            snippet: "Zoom in to see more!",
          ),
          icon: await _getClusterBitmap(_getClusterSize(cluster.count),
              text: cluster.count.toString()),
        );
      }
      var art = cluster.items.first;
      return Marker(
          markerId: MarkerId(art.name),
          position: art.location,
          infoWindow: InfoWindow(
            onTap: () => navigateToDetailsPage(mapsPage.context, art),
            title: art.name,
            snippet: art.description,
          ));
    };

/// Navigates to the details page.
void navigateToDetailsPage(BuildContext context, PublicArt art) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => DetailsPage(art)));
}

/// Returns the size of the cluster given the number of markers it contains.
int _getClusterSize(clusterCount) {
  final size = (baseSize + (pow(clusterCount, exponent) * scaleFactor)).toInt();
  return size;
}

/// Creates the Marker Bitmap given the size and text.
Future<BitmapDescriptor> _getClusterBitmap(int size, {String? text}) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint green = Paint()..color = Colors.green.withAlpha(alpha1);
  final Paint black = Paint()..color = Colors.black.withAlpha(alpha2);

  canvas.drawCircle(Offset(size / offsetSizeDivisor, size / offsetSizeDivisor),
      size / innerCircleRadiusDivisor, black);
  canvas.drawCircle(Offset(size / offsetSizeDivisor, size / offsetSizeDivisor),
      size / outerCircleRadiusDivisor, green);

  if (text != null) {
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
          fontSize: size / fontSizeDivisor,
          color: Colors.white,
          fontWeight: FontWeight.normal),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / offsetSizeDivisor - painter.width / offsetSizeDivisor,
          size / offsetSizeDivisor - painter.height / offsetSizeDivisor),
    );
  } else {
    return BitmapDescriptor.defaultMarker;
  }

  final img = await pictureRecorder.endRecording().toImage(size, size);
  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
}

/// Creates markers for each PublicArt object.
Future<void> addMarkers() async {
  mapsPage.markers.clear();
  for (final art in mapsPage.publicArts) {
    final marker = Marker(
      markerId: MarkerId(art.name),
      position: LatLng(art.latitude, art.longitude),
      infoWindow: InfoWindow(
        onTap: () => {
          Navigator.push(
            mapsPage.context,
            MaterialPageRoute(builder: (context) => DetailsPage(art)),
          )
        },
        title: art.name,
        snippet: art.description,
      ),
    );

    mapsPage.addMarker(marker);
  }
}
