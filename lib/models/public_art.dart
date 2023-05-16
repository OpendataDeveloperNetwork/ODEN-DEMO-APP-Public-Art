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
  final String city;
  final String country;
  final String region;
  final String? description;
  final String? link;
  final String? artist;
  final double? distance;
  final String? dateInstalled;
  final List? imageUrls;
  final String? material;
  final String? dateCreated;
  @Id(assignable: true)
  final int id;

  PublicArt({
    required this.name,
    required latitude,
    required longitude,
    required this.region,
    required this.city,
    required this.country,
    id,
    this.dateInstalled,
    this.material,
    this.description,
    this.link,
    this.distance,
    this.artist,
    this.imageUrls,
    this.dateCreated,
  })  : _location = LatLng(latitude, longitude),
        id = id ?? 0;

  @override
  LatLng get location => _location;
  double get latitude => location.latitude;
  double get longitude => location.longitude;

  @override
  String toString() {
    return 'PublicArt{\nid: $id\nname: $name,\n latitude: $latitude,\n longitude: $longitude,\n description: $description,\n link: $link\t}';
  }
}
