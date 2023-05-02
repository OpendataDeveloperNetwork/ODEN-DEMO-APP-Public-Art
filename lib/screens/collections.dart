import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import '../components/app_bar.dart';

///
/// This contains the collections page.
///
class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // Dummy data
  List<String> countries = ['Canada'];
  List<String> regions = ['British Columbia'];
  List<String> cities = ['Vancouver', 'New Westminster'];

  String? selectedCountry;
  String? selectedRegion;
  String? selectedCity;

  // Generate dummy art pieces data
  List<Map<String, dynamic>> generateDummyData() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 10; i++) {
      data.add({
        'name': 'Art Piece ${i + 1}',
        'country': 'Canada',
        'region': 'British Columbia',
        'city': i < 5 ? 'Vancouver' : 'New Westminster',
        'image': null,
      });
    }

    return data;
  }

  List<Map<String, dynamic>> allArtPieces = [];
  List<Map<String, dynamic>> filteredArtPieces = [];

  @override
  void initState() {
    super.initState();
    allArtPieces = generateDummyData();
    filterData();
  }

  void filterData() {
    setState(() {
      filteredArtPieces = allArtPieces.where((artPiece) {
        return (selectedCountry == null ||
            artPiece['country'] == selectedCountry) &&
            (selectedRegion == null || artPiece['region'] == selectedRegion) &&
            (selectedCity == null || artPiece['city'] == selectedCity);
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
                  filterData();
                });
              }),
              buildDropdown('Region', regions, selectedRegion, (value) {
                setState(() {
                  selectedRegion = value;
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

  DropdownButton<String> buildDropdown(String hint,
      List<String> items,
      String? selectedItem,
      Function(String?) onChanged,) {
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
