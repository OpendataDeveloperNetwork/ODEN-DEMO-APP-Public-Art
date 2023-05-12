import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeolocatorService {
  static Future<Position> getCurrentLocation() async {
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

  static Future<Map<String, String>> reverseGeocoding(
      double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      return {
        "street": place.street.toString(),
        "city": place.locality.toString(),
        "region": place.administrativeArea.toString(),
        "code": place.postalCode.toString(),
        "country": place.country.toString()
      };
    } on PlatformException catch (err) {
      return {
        "street": "Unknown",
        "city": "Unknown",
        "region": "Unknown",
        "code": "Unknown",
        "country": "Unknown"
      };
    }
  }
}
