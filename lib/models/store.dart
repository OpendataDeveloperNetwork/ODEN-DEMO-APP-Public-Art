import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oden_app/models/profile_public_art.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart'; // created by `flutter pub run build_runner build`
import './geolocator.dart';
import 'package:geolocator/geolocator.dart';

class ObjectBoxDatabase {
  /// The Store of this app.
  final Store _store;
  late final Box<PublicArt> _publicArts;

  ObjectBoxDatabase._create(this._store) {
    _publicArts = Box<PublicArt>(_store);
  }

  Future<void> populateData(data) async {
    DateTime start = DateTime.now();

    for (var i = 0; i < data.length; i++) {
      final publicArt = await jsonToPublicArt(data[i], i);
      addPublicArt(publicArt);
    }
    DateTime end = DateTime.now();
    print(
        "Time taken to retrieve data from json file: ${end.difference(start).inSeconds.toString()} seconds");
  }

  // Creates a public art object
  jsonToPublicArt(publicArtJSON, int id) async {
    double lat =
        double.parse(publicArtJSON["coordinates"]["latitude"].toString());
    double long =
        double.parse(publicArtJSON["coordinates"]["longitude"].toString());
    Position pos = await GeolocatorService.getCurrentLocation();
    double distanceBetweenLocations =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, long);
    String name = publicArtJSON["name"];
    String? description = publicArtJSON["description"];
    String? artist = publicArtJSON["artist"];
    String? material = publicArtJSON["material"];
    String? dateCreated =
        publicArtJSON['dates']?['created']?['year'].toString();
    String? dateInstalled =
        publicArtJSON['dates']?['installed']?['year'].toString();
    String country = publicArtJSON['labels']['country'];
    String region = publicArtJSON['labels']['region'];
    String city = publicArtJSON['labels']['city'];
    dynamic imageUrls = publicArtJSON['image_urls']?[0];
    return PublicArt(
        id: id,
        name: name,
        latitude: lat,
        longitude: long,
        dateInstalled: dateInstalled,
        description: description,
        artist: artist,
        imageUrls: imageUrls,
        country: country,
        city: city,
        region: region,
        material: material,
        dateCreated: dateCreated,
        distance: distanceBetweenLocations / 1000);
  }

  /// Create an instance of ObjectBox to use throughout the app.
  /// Pass in a list of data and a version
  static Future<ObjectBoxDatabase> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "objectbox-testing"));
    return ObjectBoxDatabase._create(store);
  }

  void addPublicArt(PublicArt publicArt) {
    if (!isPublicArtInDatabase(publicArt)) {
      _publicArts.put(publicArt);
    }
  }

  bool isPublicArtInDatabase(PublicArt publicArt) {
    final query =
        _publicArts.query(PublicArt_.name.equals(publicArt.name)).build();
    final result = query.find();
    return result.isNotEmpty;
  }

  List<PublicArt> getAllPublicArts() {
    return _publicArts.getAll();
  }

  PublicArt getPublicArt(ProfilePublicArt publicArt) {
    final query = _publicArts
        .query(PublicArt_.name.equals(publicArt.name))
        .build()
        .find();
    return query[0];
  }
}
