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

  Location({required name, required latitude, required longitude})
      : _name = name,
        _latitude = latitude,
        _longitude = longitude;

  String get name => _name;

  double get latitude => _latitude;

  double get longitude => _longitude;
}

class PublicArt extends Location {
  final String _description;
  final String _link;
  final String _address;
  final String _artist;
  final double _distance;
  final String _city;
  final String _country;
  final String _region;

  PublicArt(
      {required super.name,
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
      : _description = description ?? "No description available",
        _link = link ?? "No link available",
        _address = address ?? "No address",
        _artist = artist ?? "No artist",
        _distance = distance ?? 0,
        _city = city ?? "No city",
        _country = country ?? "No country",
        _region = region ?? "No region";

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
    return 'PublicArt{\nname: $name,\n latitude: $latitude,\n longitude: $longitude,\n description: $_description,\n link: $_link\t}';
  }
}
