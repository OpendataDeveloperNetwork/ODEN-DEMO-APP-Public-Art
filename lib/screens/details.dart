import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../components/app_bar.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
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
                        SizedBox(width: 10),
                        Text(
                          "Title of Art",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 200),
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
                      const SizedBox(width: 50),
                      const Text("distance", style : TextStyle(fontSize: 20))
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Description : ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                        SizedBox(height: 25),
                        Text("Artist : ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20)),
                        SizedBox(height: 25),
                        Text("Address : ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 20))
                      ],
                    )),
              ),
            ],
          ),
        ));
  }
}
