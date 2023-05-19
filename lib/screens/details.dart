import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:oden_app/models/auth.dart';
import 'package:oden_app/models/firebase_repo.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../components/profile_button_app_bar.dart';
import '../models/geolocator.dart';

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
    artDetails = {};
    if (art.dateCreated != null) artDetails['Date Created'] = art.dateCreated;
    if (art.dateInstalled != null)
      artDetails['Date Installed'] = art.dateInstalled;
    if (art.description != null) artDetails['Description'] = art.description;
    if (art.artist != null) artDetails['Artist'] = art.artist;
    if (art.material != null) artDetails['Material'] = art.material;
    artDetails['Location'] = "${art.region}, ${art.city}, ${art.country}";
  }

  @override
  State<DetailsPageBody> createState() => _DetailsPageBodyState();
}

class _DetailsPageBodyState extends State<DetailsPageBody> {
  late bool _isFavourite = false;
  String image = "";
  double distance = -2;
  late LatLng current_pos;

  @override
  void initState() {
    calculateDistance(widget.art.latitude, widget.art.longitude);
    validateImage(widget.art.imageUrls);

    Future<bool> checkPublicArt =
        FirebaseUserRepo().isPublicArtFavourited(Auth().uid, widget.art);
    checkPublicArt.then((value) => setState(() {
          _isFavourite = value;
        }));
    super.initState();
  }

  void isFavourited() {
    if (Auth().isLoggedIn) {
      setState(() {
        _isFavourite = !_isFavourite;
        if (_isFavourite) {
          FirebaseUserRepo().addPublicArtToFavourites(Auth().uid, widget.art);
        } else {
          FirebaseUserRepo()
              .removePublicArtFromFavourites(Auth().uid, widget.art);
        }
      });
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> validateImage(List? imageUrls) async {
    http.Response res;

    if (imageUrls != null) {
      for (String url in imageUrls) {
        print("hello $url");
        try {
          res = await http.get(Uri.parse(url));
        } catch (e) {
          continue;
        }

        if (res.statusCode != 200) continue;
        Map<String, dynamic> data = res.headers;

        setState(() {
          image = checkIfImage(data['content-type']) ? url : "";
        });
      }
    }
  }

  bool checkIfImage(String param) {
    if (param == 'image/jpeg' ||
        param == 'image/png' ||
        param == 'image/gif' ||
        param == 'image/JPEG' ||
        param == 'image/PNG') {
      return true;
    }
    return false;
  }

  Future<void> calculateDistance(double lat, double long) async {
    Position pos = await GeolocatorService.getCurrentLocation();
    current_pos = LatLng(pos.latitude, pos.longitude);
    setState(() {
      distance =
          Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, long);
    });
  }

  Future<void> launchMapUrl() async {
    String address =
        '${current_pos.latitude},${current_pos.longitude}/${widget.art.latitude},${widget.art.longitude}';
    String googleMapUrl = "https://www.google.com/maps/dir/$address";
    String appleMapUrl = "http://maps.apple.com/?q=$address";
    if (Platform.isAndroid) {
      try {
        if (await canLaunchUrlString(googleMapUrl)) {
          await launchUrlString(googleMapUrl,
              mode: LaunchMode.externalApplication);
        }
      } catch (error) {
        throw ("Cannot launch Google map");
      }
    }
    if (Platform.isIOS) {
      try {
        if (await canLaunchUrlString(appleMapUrl)) {
          await launchUrlString(appleMapUrl,
              mode: LaunchMode.externalApplication);
        }
      } catch (error) {
        throw ("Cannot launch Apple map");
      }
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
                alignment: Alignment.centerLeft,
                color: const Color(0xFF16BCD2),
                child: Row(
                  children: [
                    const BackButton(
                      color: Colors.white,
                    ),
                    Expanded(
                        child: Text(widget.art.name,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.white))),
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
            flex: 3,
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: 180,
                          )
                        : Image.asset(
                            "assets/images/icon.png",
                            width: 180,
                          )),
                Column(
                  children: [
                    Container(
                      width: 125,
                      margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text(
                          "You are ${(distance / 1000).round()} km away",
                          style: const TextStyle(fontSize: 20)),
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 25, 110, 5),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          onPressed: () {
                            launchMapUrl();
                          },
                          color: Colors.white,
                          icon: const Icon(Icons.drive_eta_sharp),
                        ))
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: widget.artDetails.keys.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black87),
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                    width: 500,
                    child: ListView(children: [
                      ...widget.artDetails.keys.map((key) {
                        return Text("\n$key : ${widget.artDetails[key]}",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white54));
                      }).toList(),
                    ]))
                : const Center(
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(Icons.not_listed_location))),
          ),
        ],
      ),
    );
  }
}
