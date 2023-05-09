import 'package:flutter/material.dart';
import '../components/profile_button_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


///
/// This contains the collections page.
///
class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBarWidget(context),
      body: FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // this is the value of the dropdown menu
  String? selectedCountry;
  String? selectedRegion;
  String? selectedCity;

  // for loading indicator
  bool isLoading = true;

  // Initialize the nested data structure as an empty map
  Map<String, Map<String, List<String>>> countryRegionCityData = {};

  List<String> countries = [];
  List<String> regions = [];
  List<String> cities = [];

  void updateRegions() {
    if (selectedCountry != null) {
      regions = countryRegionCityData[selectedCountry]!.keys.toList();
    } else {
      regions = [];
    }
  }

  void updateCities() {
    if (selectedRegion != null) {
      cities = countryRegionCityData[selectedCountry]![selectedRegion]!;
    } else {
      cities = [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDataFromFirestore() async {
    List<Map<String, dynamic>> data = [];
    Map<String, Map<String, List<String>>> locationData = {};

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('Categories')
        .doc('Public_Art')
        .collection('Items')
        .get();

    for (var doc in querySnapshot.docs) {

      // for debugging purposes
      print('Document data: ${doc.data()}');

      String country = doc['labels']['countryCode'];
      String region = doc['labels']['regionCode'];
      String city = doc['labels']['cityCode'];

      // Update the location data structure
      if (!locationData.containsKey(country)) {
        locationData[country] = {};
      }
      if (!locationData[country]!.containsKey(region)) {
        locationData[country]![region] = [];
      }
      if (!locationData[country]![region]!.contains(city)) {
        locationData[country]![region]!.add(city);
      }

      Map<String, dynamic> artPiece = {
        'name': doc['name'],
        'country': country,
        'region': region,
        'city': city,
        'image': null,
      };
      data.add(artPiece);
    }

    // Update the countryRegionCityData map
    countryRegionCityData = locationData;

    // Update the countryRegionCityData map and refresh the UI
    setState(() {
      countryRegionCityData = locationData;
      countries = countryRegionCityData.keys.toList();
    });

    return data;
  }

  List<Map<String, dynamic>> allArtPieces = [];
  List<Map<String, dynamic>> filteredArtPieces = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore().then((data) {
      setState(() {
        allArtPieces = data;
        countries = countryRegionCityData.keys.toList();
        filterData();
        isLoading = false;
      });
    });

  }


  void filterData() {
    setState(() {
      filteredArtPieces = allArtPieces.where((artPiece) {
        return (selectedCountry == null ||
                artPiece['country'] == selectedCountry) &&
            (selectedRegion == null ||
                selectedRegion == 'ALL' ||
                artPiece['region'] == selectedRegion) &&
            (selectedCity == null ||
                selectedCity == 'ALL' ||
                artPiece['city'] == selectedCity);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Filter Public Art')),
      body: Column(
        children: [
          // Dropdown menus for country, region, and city filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildDropdown('Country', countries, selectedCountry, (value) {
                setState(() {
                  selectedCountry = value;
                  updateRegions();
                  selectedRegion = null;
                  updateCities();
                  selectedCity = null;
                  filterData();
                });
              }),
              buildDropdown('Region', regions, selectedRegion, (value) {
                setState(() {
                  selectedRegion = value;
                  updateCities();
                  selectedCity = null;
                  filterData();
                });
              }),
              buildDropdown('City', cities, selectedCity, (value) {
                setState(() {
                  selectedCity = value;
                  filterData();
                });
              }),
            ],
          ),
          // Add a Padding widget to display the number of filtered results
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${filteredArtPieces.length} result(s) found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // ListView to display filtered art pieces
          Expanded(
            child: ListView.builder(
              itemCount: filteredArtPieces.length,
              itemBuilder: (context, index) {
                final artPiece = filteredArtPieces[index];
                return ListTile(
                  leading: Image.asset(
                    artPiece['image'] ?? 'assets/images/logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(artPiece['name']),
                  subtitle: Text(
                      '${artPiece['city']}, ${artPiece['region']}, ${artPiece['country']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  DropdownButton<String> buildDropdown(
    String hint,
    List<String> items,
    String? selectedItem,
    Function(String?) onChanged,
  ) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: selectedItem,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
