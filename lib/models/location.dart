// ---------------------- //
// ----- Location ------- //
// ---------------------- //

///
/// Location class contains all value for locations. It must have a name to present
/// on the button and a longitude and latitude to use for the Googles API origin.
///
class Location {
  final String name;

  /// The latitude to use in the API call e.g. 51.5074
  final double latitude;

  /// The longitude to use in the API call e.g. 0.1278
  final double longitude;

  Location(this.name, this.latitude, this.longitude);
}
