import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oden_app/models/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oden_app/blocs/firebase_model.dart';
import 'package:oden_app/blocs/maps_model.dart';

class PublicArtsProvider with ChangeNotifier {
  final List<PublicArt> _publicArts = [];

  PublicArtsProvider() {
    retrieveData();
  }

  int get length => _publicArts.length;

  List<PublicArt> get publicArts => _publicArts;

  void addPublicArt(PublicArt publicArt) {
    _publicArts.add(publicArt);
    notifyListeners();
  }

  void retrieveData() {
    FirebaseModel().getPublicArts().then((publicArtsData) async {
      for (var doc in publicArtsData.docs) {
        PublicArt publicArt = await _createPublicArt(doc);
        addPublicArt(publicArt);
        print("Added ${publicArt.name}");
      }
      print("Retrieved all");
    });
  }

  Future<PublicArt> _createPublicArt(QueryDocumentSnapshot data) async {
    double lat = double.parse(data["coordinates"]["latitude"].toString());
    double long = double.parse(data["coordinates"]["longitude"].toString());
    Position pos = await MapsModel().getCurrentLocation();
    double distanceBetweenLocations =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, long);
    return PublicArt(
        id: data.id,
        name: data["name"],
        latitude: lat,
        longitude: long,
        city: data["labels"]["cityCode"],
        country: data["labels"]["countryCode"],
        region: data["labels"]["regionCode"],
        distance: distanceBetweenLocations / 1000);
  }
}
