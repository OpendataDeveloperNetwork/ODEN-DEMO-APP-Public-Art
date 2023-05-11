// ---------------------- //
// ----- Location ------- //
// ---------------------- //

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:objectbox/objectbox.dart';

///
/// Location class contains all value for locations. It must have a name to present
/// on the button and a longitude and latitude to use for the Googles API origin.
///
class Location with ClusterItem {
  final String _name;

  /// The latitude to use in the API call e.g. 51.5074
  final LatLng _location;

  Location({required name, required latitude, required longitude})
      : _name = name ?? "No name",
        _location = LatLng(latitude, longitude);

  @override
  LatLng get location => _location;
  String get name => _name;
  double get latitude => location.latitude;
  double get longitude => location.longitude;
}

@Entity()
class PublicArt extends Location {
  final String _description;
  final String _link;
  final String _address;
  final String _artist;
  final double _distance;
  final String _city;
  final String _country;
  final String _region;
  final String _id;

  PublicArt(
      {required id,
      required super.name,
      required super.latitude,
      required super.longitude,
      description,
      link,
      address,
      artist,
      distance,
      city,
      country,
      region})
      : _id = id ?? "No id",
        _description = description ?? "No description available",
        _link = link ?? "No link available",
        _address = address ?? "No address",
        _artist = artist ?? "No artist",
        _distance = distance ?? 0,
        _city = city ?? "No city",
        _country = country ?? "No country",
        _region = region ?? "No region";

  String get id => _id;

  String get description => _description;

  String get link => _link;

  String get address => _address;

  String get artist => _artist;

  double get distance => _distance;

  String get city => _city;

  String get country => _country;

  String get region => _region;

  @override
  String toString() {
    return 'PublicArt{\nid: $id\nname: $name,\n latitude: $latitude,\n longitude: $longitude,\n description: $_description,\n link: $_link\t}';
  }
}
