import 'package:flutter/material.dart';

///
/// This is a list view widget for all the favourites.
///

class FavouritesListView extends StatefulWidget {
  const FavouritesListView({super.key});

  @override
  State<FavouritesListView> createState() => _FavouritesListViewState();
}

class _FavouritesListViewState extends State<FavouritesListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Row(children: const [
              Expanded(child: ListTile(title: Text("Favourites")))
            ]),
          );
        });
  }
}
