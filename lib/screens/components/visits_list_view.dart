import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oden_app/models/public_art.dart';
import '../../models/profile_public_art.dart';
import '../../models/firebase_user.dart';
import '../../models/auth.dart';
import 'package:oden_app/screens/details.dart';

///
/// This contains the list view for the visits.
///

class VisitsListView extends StatefulWidget {
  final List<ProfilePublicArt> _visits;
  const VisitsListView(this._visits, {super.key});

  @override
  State<VisitsListView> createState() => _VisitsListViewState();
}

class _VisitsListViewState extends State<VisitsListView> {
  Future unVisit(callback, publicArtId) {
    setState(() {
      callback();
    });
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Unvisit'),
            content: const Text('Are you sure you want to unvisit?'),
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

  // void toDetailsPage(String publicId) async {
  //   DocumentSnapshot data =
  //   await FirebaseUser().getPublicArt(Auth().uid!, publicId);
  //   PublicArt publicArt = PublicArt(
  //       id: int.parse(publicId),
  //       name: data["name"],
  //       latitude: double.parse(data['coordinates']['latitude']),
  //       longitude: double.parse(data['coordinates']['longitude']));
  //   if (context.mounted) {
  //     navigationToDetailsPage(publicArt);
  //   }
  // }

  void navigationToDetailsPage(PublicArt publicArt) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailsPage(art: publicArt)));
  }

  void isCanceled(callback) {
    Navigator.of(context).pop();
    setState(() {
      callback();
    });
  }

  void isConfirmed(publicArtId) {
    setState(() {
      widget._visits.removeWhere((element) => element.id == publicArtId);
    });
    FirebaseUser().removePublicArtFromVisits(Auth().uid!, publicArtId);
    Navigator.of(context).pop();
  }

  Card cardBuilder(ProfilePublicArt favorite) {
    return Card(
      child: Row(children: [
        Expanded(
            child: ListTile(
          title: Text(favorite.name),
          subtitle: Text(favorite.date),
          // onTap: () => toDetailsPage(favorite.id),
        )),
        IconButton(
          onPressed: () => unVisit(favorite.toggleFavourite, favorite.id),
          icon: const Icon(Icons.remove),
          iconSize: 45,
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget._visits.length,
        itemBuilder: (BuildContext context, int index) {
          var favorite = widget._visits[index];
          return cardBuilder(favorite);
        });
  }
}
