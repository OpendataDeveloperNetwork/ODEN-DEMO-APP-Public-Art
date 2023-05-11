import 'package:flutter/material.dart';
import '../components/profile_button_app_bar.dart';
import 'package:oden_app/models/location.dart';
import 'package:oden_app/bloc/firebase_model.dart';
import 'package:oden_app/models/auth.dart';

class DetailsPage extends StatelessWidget {
  final PublicArt art;

  DetailsPage({super.key, required this.art});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: profileAppBarWidget(context, true),
        body: DetailsPageBody(art: art));
  }
}

class DetailsPageBody extends StatefulWidget {
  final PublicArt art;
  late Map artDetails;

  DetailsPageBody({super.key, required this.art}) {
    artDetails = {
      'Description': art.description,
      'Address': art.address,
      'Artist': art.artist
    };
  }

  @override
  State<DetailsPageBody> createState() => _DetailsPageBodyState();
}

class _DetailsPageBodyState extends State<DetailsPageBody> {
  late bool _isFavourite = false;

  @override
  void initState() {
    Future<bool> checkPublicArt =
        FirebaseModel().isPublicArtFavourited(Auth().uid, widget.art.id);
    checkPublicArt.then((value) => setState(() {
          _isFavourite = value;
        }));
    // TODO: implement initState
    super.initState();
  }

  void isFavourited() {
    if (Auth().isLoggedIn) {
      setState(() {
        _isFavourite = !_isFavourite;
        if (_isFavourite) {
          FirebaseModel().addPublicArtToFavourites(Auth().uid, widget.art);
        } else {
          FirebaseModel()
              .removePublicArtFromFavourites(Auth().uid, widget.art.id);
        }
      });
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Flexible(
            child: Container(
                color: Colors.green,
                child: Row(
                  children: [
                    const BackButton(),
                    const SizedBox(width: 275),
                    IconButton(
                      onPressed: isFavourited,
                      icon: Icon(
                        _isFavourite ? Icons.star : Icons.star_outline,
                        color: Colors.yellow,
                      ),
                      iconSize: 40,
                    )
                  ],
                )),
          ),
          Expanded(
              child: Center(
                  child: Container(
                      width: 400,
                      margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                      padding: const EdgeInsets.all(5),
                      child: Text(widget.art.name,
                          style: const TextStyle(fontSize: 28))))),
          Expanded(
              flex: 3,
              child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Image.network(
                        "https://assets.simpleviewinc.com/simpleview/image/upload/c_limit,h_1200,q_75,w_1200/v1/clients/vancouverbc/vancouver-public-art-mini-guide_ad75d4cc-dd05-4ab5-8320-cd2df84e83f5.jpg",
                        width: 200,
                      )),
                  SizedBox(
                      width: 160,
                      child: Text(
                          "You are ${widget.art.distance.round()} km away",
                          style: const TextStyle(fontSize: 20)))
                ],
              )),
          Expanded(
            flex: 7,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black87),
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                width: 500,
                child: ListView(children: [
                  ...widget.artDetails.keys.map((key) {
                    if (!widget.artDetails[key].toString().startsWith("No")) {
                      return Text(key,
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white38));
                    }
                    return const Text("");
                  }).toList(),
                ])),
          ),
        ],
      ),
    );
  }
}
