// ---------------------- //
// ----- Location ------- //
// ---------------------- //

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///
/// Location class contains all value for locations. It must have a name to present
/// on the button and a longitude and latitude to use for the Googles API origin.
///
class Location with ClusterItem {
  final String _name;

  /// The latitude to use in the API call e.g. 51.5074
  final LatLng _location;

  Location({
    required name, 
    required latitude, 
    required longitude
  }) : 
    _name = name,
    _location = LatLng(latitude, longitude);

  @override
  LatLng get location => _location;
  String get name => _name;
  double get latitude => location.latitude;
  double get longitude => location.longitude;

}

class PublicArt extends Location {
  final String _description;
  final String _link;

  PublicArt({
    required super.name, 
    required super.latitude,
    required super.longitude,
    description, 
    link
  }) : 
    _description = description ?? "No description available",
    _link = link ?? "No link available";

  String get description => _description;
  String get link => _link;

  @override
  String toString() {
    return 'PublicArt{\nname: $name,\n latitude: $latitude,\n longitude: $longitude,\n description: $_description,\n link: $_link\t}';
  }

}

/// Takes in JSON data and returns a PublicArt object.
PublicArt jsonToPublicArt(publicArtJSON, dataLink) {
  return PublicArt(
      name: publicArtJSON["title"],
      latitude: publicArtJSON["point"]["coordinates"][1],
      longitude: publicArtJSON["point"]["coordinates"][0],
      description: publicArtJSON["short_desc"],
      link: dataLink);
}
