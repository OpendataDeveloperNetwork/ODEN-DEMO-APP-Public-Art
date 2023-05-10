import 'package:flutter/material.dart';
import '../../models/profile_public_art.dart';

///
/// This is a list view widget for all the favourites.
///

class FavouritesListView extends StatefulWidget {
  final List<ProfilePublicArt> _favourites;
  const FavouritesListView(this._favourites, {super.key});

  @override
  State<FavouritesListView> createState() => _FavouritesListViewState();
}

class _FavouritesListViewState extends State<FavouritesListView> {
  void unFavourite(callback, publicArtId) {
    setState(() {
      callback();
    });
    widget._favourites.removeWhere((element) => element.id == publicArtId);
  }

  Dismissible cardBuilder(ProfilePublicArt favorite) {
    return Dismissible(
      key: Key(favorite.id),
      child: Row(children: [
        Expanded(
            child: ListTile(
                title: Text(favorite.name), subtitle: Text(favorite.date))),
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
