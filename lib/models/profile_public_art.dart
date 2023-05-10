///
/// A class responsible for representing public art from the profile's
/// collection. This may be public arts that the user has favourited or
/// visited.
///
class ProfilePublicArt {
  final String date;
  final String name;
  final String _id;
  bool isFavourited = true;

  ProfilePublicArt(this.date, this.name, this._id);

  String get id => _id;

  void toggleFavourite() {
    isFavourited = !isFavourited;
  }

  @override
  String toString() {
    return 'ProfileArts{\nid: $id\nname: $name,\n date: $date \n\t}';
  }
}
