import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oden_app/models/location.dart';
import '../../models/profile_public_art.dart';
import '../../bloc/firebase_model.dart';
import '../../models/auth.dart';
import 'package:oden_app/screens/details.dart';

///
/// This is a list view widget for all the favourites.
///

class FavouritesListView extends StatefulWidget {
  final List<ProfilePublicArt> _favourites;
  const FavouritesListView(this._favourites, {super.key});

  @override
  State<FavouritesListView> createState() => _FavouritesListViewState();
}

class _FavouritesListViewState extends State<FavouritesListView>
    with SingleTickerProviderStateMixin {
  Future unFavourite(callback, publicArtId) {
    setState(() {
      callback();
    });
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Unfavourite'),
            content: const Text('Are you sure you want to unfavourite?'),
            actions: [
              TextButton(
                  onPressed: () => isCanceled(callback),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => isConfirmed(publicArtId),
                  child: const Text('Confirm'))
            ],
          );
        });
  }

  void isCanceled(callback) {
    Navigator.of(context).pop();
    setState(() {
      callback();
    });
  }

  void isConfirmed(publicArtId) {
    setState(() {
      widget._favourites.removeWhere((element) => element.id == publicArtId);
    });
    FirebaseModel().removePublicArtFromFavourites(Auth().uid!, publicArtId);
    Navigator.of(context).pop();
  }

  void toDetailsPage(String publicId) async {
    DocumentSnapshot data =
        await FirebaseModel().getPublicArt(Auth().uid!, publicId);
    PublicArt publicArt = PublicArt(
        id: publicId,
        name: data["name"],
        latitude: double.parse(data['coordinates']['latitude']),
        longitude: double.parse(data['coordinates']['longitude']));
    if (context.mounted) {
      navigationToDetailsPage(publicArt);
    }
  }

  void navigationToDetailsPage(PublicArt publicArt) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsPage(art: publicArt)))
        .then((value) => reloadListView(publicArt));
  }

  void reloadListView(PublicArt publicArt) async {
    bool isFavourited =
        await FirebaseModel().isPublicArtFavourited(Auth().uid, publicArt.id);
    if (!isFavourited) {
      setState(() {
        widget._favourites.removeWhere((element) => element.id == publicArt.id);
      });
    }
  }

  Card cardBuilder(ProfilePublicArt favorite) {
    return Card(
      child: Row(children: [
        Expanded(
            child: ListTile(
          title: Text(favorite.name),
          subtitle: Text(favorite.date),
          onTap: () => toDetailsPage(favorite.id),
        )),
        IconButton(
          onPressed: () => unFavourite(favorite.toggleFavourite, favorite.id),
          icon: Icon(
            favorite.isFavourited ? Icons.star : Icons.star_outline,
            color: Colors.yellow,
          ),
          iconSize: 45,
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget._favourites.length,
        itemBuilder: (BuildContext context, int index) {
          var favorite = widget._favourites[index];
          return cardBuilder(favorite);
        });
  }
}
