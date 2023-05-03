// ---------------------- //
// ----- Location ------- //
// ---------------------- //

///
/// Location class contains all value for locations. It must have a name to present
/// on the button and a longitude and latitude to use for the Googles API origin.
///
class Location {
  final String _name;

  /// The latitude to use in the API call e.g. 51.5074
  final double _latitude;

  /// The longitude to use in the API call e.g. 0.1278
  final double _longitude;

  Location({
    required name, 
    required latitude, 
    required longitude
  }) : 
    _name = name,
    _latitude = latitude,
    _longitude = longitude;

  String get name => _name;
  double get latitude => _latitude;
  double get longitude => _longitude;

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
    return 'PublicArt{name: $name, latitude: $latitude, longitude: $longitude, description: $_description, link: $_link}';
  }

}
