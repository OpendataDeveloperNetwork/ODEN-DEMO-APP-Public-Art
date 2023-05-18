import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oden_app/models/public_art.dart';
import '../../main.dart';
import '../../models/profile_public_art.dart';
import '../../models/firebase_repo.dart';
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

  void toDetailsPage(ProfilePublicArt profilePublicArt) async {
    PublicArt publicArt = db.getPublicArt(profilePublicArt);
    if (context.mounted) {
      navigationToDetailsPage(publicArt);
    }
  }

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

  void isConfirmed(ProfilePublicArt publicArt) {
    setState(() {
      widget._visits.removeWhere((element) =>
          element.city == publicArt.city &&
          element.country == publicArt.country &&
          element.region == publicArt.region &&
          element.name == publicArt.name);
    });
    FirebaseUserRepo().removePublicArtFromVisits(Auth().uid!, publicArt);
    Navigator.of(context).pop();
  }

  Card cardBuilder(ProfilePublicArt visit) {
    return Card(
      child: Row(children: [
        Expanded(
            child: ListTile(
          title: Text(visit.name),
          subtitle: Text(visit.date),
          onTap: () => toDetailsPage(visit),
        )),
        IconButton(
          onPressed: () => unVisit(visit.toggleFavourite, visit),
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
          var visit = widget._visits[index];
          return cardBuilder(visit);
        });
  }
}
