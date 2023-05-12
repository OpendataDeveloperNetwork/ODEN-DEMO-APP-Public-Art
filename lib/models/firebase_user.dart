import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:intl/intl.dart';

///
/// This class is responsible for accessing the firebase and retrieving
/// or saving data of the user.
///

class FirebaseUser {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference profiles = firestore.collection("Profiles");
  late final CollectionReference categories =
      firestore.collection("Categories");

  Future<bool> isPublicArtFavourited(String? uid, int? publicArtId) async {
    if (uid == null) return Future.value(false);
    final data = await profiles.doc(uid).collection("Favorites").get();
    if (data.size == 0) return Future.value(false);
    for (var doc in data.docs) {
      if (doc["id"] == publicArtId) return Future.value(true);
    }
    return Future.value(false);
  }

  Future<void> addPublicArtToFavourites(
      String? uid, PublicArt publicArt) async {
    if (await isPublicArtFavourited(uid, publicArt.id)) return;
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd hh:mm').format(now);
    Map<String, dynamic> data = {
      "id": publicArt.id,
      "name": publicArt.name,
      "date": date
    };
    if (uid == null) return;
    await profiles
        .doc(uid)
        .collection("Favorites")
        .add(data)
        .then((_) => print("Added ${publicArt.id} to $uid"))
        .catchError((onError) => print("failed to add ${publicArt.id}"));
  }

  Future<void> removePublicArtFromFavourites(
      String? uid, int publicArtId) async {
    final QuerySnapshot data =
        await profiles.doc(uid).collection("Favorites").get();
    if (data.size == 0) return;
    for (var doc in data.docs) {
      if (doc["id"] == publicArtId) {
        await profiles.doc(uid).collection("Favorites").doc(doc.id).delete();
        return;
      }
    }
  }

  Future<QuerySnapshot> getFavourites(String uid) async {
    final data = await profiles.doc(uid).collection("Favorites").get();
    return data;
  }

  Future<DocumentSnapshot> getPublicArt(String uid, String publicArtId) async {
    return categories
        .doc("Public_Art")
        .collection("Items")
        .doc(publicArtId)
        .get();
  }
}
