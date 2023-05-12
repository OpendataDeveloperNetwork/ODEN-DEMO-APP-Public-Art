// ---------------------- //
// ----- Location ------- //
// ---------------------- //

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:objectbox/objectbox.dart';

import 'address.dart';

///
/// Location class contains all value for locations. It must have a name to present
/// on the button and a longitude and latitude to use for the Googles API origin.
///
class Location with ClusterItem {
  final String _name;

  /// The latitude to use in the API call e.g. 51.5074
  final LatLng _location;

  Location({required name, required latitude, required longitude})
      : _name = name,
        _location = LatLng(latitude, longitude);

  @override
  LatLng get location => _location;
  String get name => _name;
  double get latitude => location.latitude;
  double get longitude => location.longitude;
}

@Entity()
class PublicArt with ClusterItem {
  final String name;
  final LatLng _location;
  final String description;
  final String link;
  final String artist;
  final double distance;
  final int dateInstalled;
  final String material;
  final String owner;
  final String type;
  final String area;
  final String imageUrl;
  final Address address;
  int id;

  PublicArt(
      {required name,
      required latitude,
      required longitude,
      this.id = 0,
      dateInstalled,
      material,
      description,
      link,
      artist,
      distance,
      owner,
      type,
      area,
      imageUrl,
      address})
      : name = name ?? "No name",
        _location = LatLng(latitude, longitude),
        description = description ?? "No description available",
        link = link ?? "No link available",
        artist = artist ?? "No artist",
        material = material ?? "No material",
        distance = distance ?? 0,
        address = address ?? "No address",
        dateInstalled = dateInstalled ?? 0,
        owner = owner ?? "No owner",
        type = type ?? "No type",
        area = area ?? "No area",
        imageUrl = imageUrl ?? "No image url";

  @override
  LatLng get location => _location;
  double get latitude => location.latitude;
  double get longitude => location.longitude;
  String get city => address.city;
  String get country => address.country;
  String get region => address.region;
  String get street => address.street;
  String get postalCode => address.code;

  @override
  String toString() {
    return 'PublicArt{\nid: $id\nname: $name,\n latitude: $latitude,\n longitude: $longitude,\n description: $description,\n link: $link\t}';
  }
}
