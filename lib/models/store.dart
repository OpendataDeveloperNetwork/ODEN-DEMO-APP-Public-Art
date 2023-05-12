import 'dart:convert';
import 'package:flutter/services.dart';
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
    // Run this first! Once
    // _publicArts.removeAll();
    if (_publicArts.isEmpty()) {
      _putDemoData();
    }
  }

  Future<void> _putDemoData() async {
    final String response =
        await rootBundle.loadString('assets/json/all-my-data.json');
    final List data = await json.decode(response)['data'];
    for (var i = 0; i < data.length; i++) {
      final publicArt = await jsonToPublicArt(data[i]);
      addPublicArt(publicArt);
      print(i);
    }
    print("Finish retrieving data from json file");
  }

  // Creates a public art object
  jsonToPublicArt(publicArtJSON) async {
    double lat =
        double.parse(publicArtJSON["coordinates"]["latitude"].toString());
    double long =
        double.parse(publicArtJSON["coordinates"]["longitude"].toString());
    Position pos = await GeolocatorService.getCurrentLocation();
    double distanceBetweenLocations =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, long);
    return PublicArt(
        name: publicArtJSON["name"],
        latitude: lat,
        longitude: long,
        dateInstalled: publicArtJSON["dates"]["installed"]["year"],
        description: publicArtJSON['description'],
        artist: publicArtJSON['artist'],
        imageUrl: publicArtJSON['image_url'],
        distance: distanceBetweenLocations / 1000);
  }

  /// Create an instance of ObjectBox to use throughout the app.
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
    } else {
      return;
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
}
