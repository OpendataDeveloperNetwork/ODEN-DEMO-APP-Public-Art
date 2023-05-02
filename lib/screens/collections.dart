import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../components/profile_button_app_bar.dart';

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

  // Nested data structure
  Map<String, Map<String, List<String>>> countryRegionCityData = {
    'Canada': {
      'British Columbia': ['Vancouver', 'New Westminster'],
    },
    'United States': {
      'California': ['Los Angeles', 'San Francisco'],
      'New York': ['New York City', 'Buffalo'],
    },
  };

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

  // Generate dummy art pieces data
// Generate dummy art pieces data
  List<Map<String, dynamic>> generateDummyData() {
    List<Map<String, dynamic>> data = [];

    // Canadian Art Pieces
    for (int i = 0; i < 5; i++) {
      data.add({
        'name': 'Canadian Art Piece ${i + 1}',
        'country': 'Canada',
        'region': 'British Columbia',
        'city': i < 3 ? 'Vancouver' : 'New Westminster',
        'image': null,
      });
    }

    // American Art Pieces
    for (int i = 0; i < 10; i++) {
      if (i < 5) {
        data.add({
          'name': 'American Art Piece ${i + 1}',
          'country': 'United States',
          'region': 'California',
          'city': i < 3 ? 'Los Angeles' : 'San Francisco',
          'image': null,
        });
      } else {
        data.add({
          'name': 'American Art Piece ${i + 1}',
          'country': 'United States',
          'region': 'New York',
          'city': i < 8 ? 'New York City' : 'Buffalo',
          'image': null,
        });
      }
    }

    return data;
  }

  List<Map<String, dynamic>> allArtPieces = [];
  List<Map<String, dynamic>> filteredArtPieces = [];

  @override
  void initState() {
    super.initState();
    countries = countryRegionCityData.keys.toList();
    allArtPieces = generateDummyData();
    filterData();
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
