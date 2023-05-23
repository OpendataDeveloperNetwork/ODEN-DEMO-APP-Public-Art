import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:oden_app/main.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../components/profile_button_app_bar.dart';
import '../models/category.dart';
import '../models/public_art.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:oden_app/transmogrifier.dart' as transmogrifier;

// ------------------------ //
// ----- Landing Page ----- //
// ------------------------ //

///
/// A class stateful that is responsible for displaying the home page.
///
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  bool isTransmogrifying = false;
  int totalData = 0;
  int currentData = 0;
  double percent = 0;
  String dbStatus = "";

  ///
  /// A private function that builds the collection button widget
  ///
  SpeedDial _buildCollectionFloatingWidget(BuildContext context) {
    ///
    /// An inner function that navigates to the collections page.
    ///
    void navigateToCollections() {
      Navigator.pushNamed(context, '/collections');
    }

    void populateData() async {
      setState(() {
        isTransmogrifying = true;
      });
      String ODENManifest =
          await rootBundle.loadString('assets/json/ODEN-manifest.json');

      dynamic data =
          await transmogrifier.transmogrify(jsonDecode(ODENManifest));
      dynamic publicArtData = await transmogrifier.transmogrify(data[0]);
      setState(() {
        isLoading = true;
        db.retrievingData.listen((data) {
          setState(() {
            debugPrint(data.toString());
            currentData = data;
            percent = currentData / totalData;
          });
        });
        dbStatus = db.isPublicArtEmpty() ? "Downloading Data" : "Updating Data";
      });
      List jsonData = publicArtData[0]['data'];
      totalData = jsonData.length;
      await db.populateData(publicArtData[0]['data']);
      setState(() {
        isLoading = false;
        isTransmogrifying = false;
      });
      debugPrint("<----- Completed Transmogrification ----->");
    }

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: const Color(0xFF000080),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: const Icon(Icons.folder_open, color: Colors.white),
            backgroundColor: const Color(0xFF000080),
            onTap: navigateToCollections,
            label: 'Collections',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: const Color(0xFF000080)),
        // FAB 2
        SpeedDialChild(
            child: const Icon(Icons.update, color: Colors.white),
            backgroundColor: const Color(0xFF000080),
            onTap: populateData,
            label: 'Update',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: const Color(0xFF000080))
      ],
    );
  }

  List<Widget> showLoading() {
    if (isLoading) {
      return [
        Text(dbStatus, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        CircularPercentIndicator(
          progressColor: Colors.blue[900],
          backgroundColor: Colors.deepPurple.shade100,
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            "${(percent * 100).toStringAsFixed(0)}%",
            style: const TextStyle(fontSize: 25),
          ),
          radius: 200,
          lineWidth: 20,
          percent: percent,
        )
      ];
    } else {
      return [
        Lottie.network(
            "https://assets2.lottiefiles.com/packages/lf20_2KHZQg.json"),
        const SizedBox(height: 20),
        const Text("Transmogrifying Open Data",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: profileAppBarWidget(context, false),
        body: isTransmogrifying
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: showLoading()),
              )
            : const HomePageBody(),
        floatingActionButton: _buildCollectionFloatingWidget(context));
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

///
/// A private class that is updates and contains the current
/// location and category chosen by the user.
///
class _HomePageBodyState extends State<HomePageBody> {
  late Size size;
  late double height;
  final Category _category = Category("Public Art", "public-art");
  final Location _location =
      Location(name: "Current Location", latitude: 0.1, longitude: 0.1);

  ///
  /// A function pushes the map page to the stack, we will pass the
  /// location and category chosen to the user here!
  ///
  void retrieveData() {
    Navigator.pushNamed(context, '/maps');
  }

  ///
  /// A private function that builds the button widgets.
  ///
  Container _buildButtonWidget(value, String title) {
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
                              color: Color(0xFF000080), width: 2)),
                      child: Text(value.name),
                    )))
          ],
        ));
  }

  ///
  /// A private function that builds the retrieve button widget.
  ///
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
                backgroundColor: const Color(0xFF16BCD2),
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
            _buildButtonWidget(_category, "Category"),
            _buildButtonWidget(_location, "Location"),
            SizedBox(height: height * 0.10),
            _buildRetrieveButton()
          ],
        ),
      ),
    ]);
  }
}
