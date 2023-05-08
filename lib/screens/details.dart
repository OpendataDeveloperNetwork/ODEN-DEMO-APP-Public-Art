import 'package:flutter/material.dart';
import '../components/profile_button_app_bar.dart';
import 'package:oden_app/models/location.dart';

class DetailsPage extends StatelessWidget {
  final PublicArt art;

  const DetailsPage(this.art, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: profileAppBarWidget(context),
        body: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Flexible(
                child: Container(
                    color: Colors.green,
                    child: Row(
                      children: const [
                        BackButton(),
                        SizedBox(width: 300),
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.star,
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
                          child: Image.network(
                            "https://assets.simpleviewinc.com/simpleview/image/upload/c_limit,h_1200,q_75,w_1200/v1/clients/vancouverbc/vancouver-public-art-mini-guide_ad75d4cc-dd05-4ab5-8320-cd2df84e83f5.jpg",
                            width: 200,
                          )),
                      SizedBox(
                         width: 175,
                         child: Text("You are ${art.distance} km away", style: const TextStyle(fontSize: 20))
                       )
                    ],
                  )),
              Expanded(
                flex: 7,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black87),
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    padding: const EdgeInsets.all(20),
                    width: 500,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name : ${art.name}\n",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20)),
                            const SizedBox(height: 25),
                            Text("Description : ${art.description}\n",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20)),
                            const SizedBox(height: 25),
                            Text("Artist : ${art.artist}\n",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20)),
                            const SizedBox(height: 25),
                            Text("Address : ${art.address}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20))
                          ],
                        )),
                    ),
              ),
            ],
          ),
        ));
  }
}
