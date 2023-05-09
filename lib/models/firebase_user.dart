import 'package:cloud_firestore/cloud_firestore.dart';

///
/// This class is responsible for accessing the firebase and retrieving
/// or saving data of the user.
///

class FirebaseUser {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference profiles = firestore.collection("Profiles");

  ///
  /// A function that adds a favourite to the user's profile database.
  ///
  Future<void> addFavourite(String? uid, String? publicId) async {
    if (uid == null || publicId == null) return;
    profiles
        .doc(uid)
        .collection("Favorites")
        .add({"id": publicId})
        .then((_) => print("Added $publicId to $uid"))
        .catchError((onError) => print("failed to add $publicId"));
  }

  ///
  /// A function that adds a visited to the user's profile database.
  ///
  Future<void> addVisit(String? uid, String? publicId) async {
    if (uid == null || publicId == null) return;
    profiles
        .doc(uid)
        .collection("Visits")
        .add({"id": publicId})
        .then((_) => print("Added $publicId to $uid"))
        .catchError((onError) => print("failed to add $publicId"));
  }
}
