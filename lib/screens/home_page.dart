import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../models/category.dart';
import '../models/location.dart';
import './map_page.dart';

// ------------------------ //
// ----- Landing Page ----- //
// ------------------------ //

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(context), body: const HomePageBody());
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  late Size size;
  late double height;
  final Category _category = Category("Public Art", "public-art");
  final Location _location = Location("Current Location", 0, 0);

  void retrieveData() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapsPage()));
  }

  Container _buildButton(value, String title) {
    return Container(
        padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => {},
                      style: OutlinedButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          side: const BorderSide(
                              color: Color(0xFF77BF4B), width: 2)),
                      child: Text(value.name),
                    )))
          ],
        ));
  }

  Container _buildRetrieveButton() {
    return Container(
        padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
        width: double.infinity,
        height: 65,
        child: ElevatedButton(
            onPressed: retrieveData,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF2D3848),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            child: const Text("Retrieve")));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;

    return Column(children: [
      const Expanded(
          child: Center(
              child: Text(
        "Let's Get Started",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ))),
      Expanded(
        flex: 3,
        child: Column(
          children: [
            _buildButton(_category, "Category"),
            _buildButton(_location, "Location"),
            SizedBox(height: height * 0.10),
            _buildRetrieveButton()
          ],
        ),
      ),
    ]);
  }
}
