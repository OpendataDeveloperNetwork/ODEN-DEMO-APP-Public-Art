// ---------------------- //
// ----- Category ------- //
// ---------------------- //

///
/// Category class contains all value for categories. As an example,
/// for public art will be Category("Public Art", "public-art")
///
class Category {
  /// The name to show on the button e.g. Public Art
  final String name;

  /// The value to use in the API call e.g. public-art
  final String value;

  Category(this.name, this.value);
}
