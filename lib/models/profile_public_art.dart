///
/// A class responsible for representing public art from the profile's
/// collection. This may be public arts that the user has favourited or
/// visited.
///
class ProfilePublicArt {
  final String date;
  final String name;
  final String city;
  final String country;
  final String region;
  bool isFavourited = true;

  ProfilePublicArt(this.date, this.name, this.city, this.country, this.region);

  void toggleFavourite() {
    isFavourited = !isFavourited;
  }

  @override
  String toString() {
    return 'ProfileArts{\ncountry: $country\nregion: $region \ncity: $city\nname: $name,\n date: $date \n\t}';
  }
}
