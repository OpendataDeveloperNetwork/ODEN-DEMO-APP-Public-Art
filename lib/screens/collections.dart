import 'package:flutter/material.dart';
import '../components/profile_button_app_bar.dart';
import './details.dart';
import 'package:oden_app/models/public_art.dart';
import 'package:oden_app/main.dart';

///
/// This contains the collections page.
///
class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBarWidget(context, false),
      body: FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  // filtering data by fields.
  bool hasDescriptionFilter = false;
  bool hasArtistFilter = false;
  bool hasMaterialFilter = false;
  bool dateCreatedFilter = false;
  bool dateInstalledFilter = false;

  // this is the value of the dropdown menu
  String? selectedCountry;
  String? selectedRegion;
  String? selectedCity;

  // for loading indicator
  bool isLoading = true;

  // Initialize the nested data structure as an empty map
  Map<String, Map<String, List<String>>> countryRegionCityData = {};

  // Initialize the lists of countries, regions, and cities
  List<String> countries = [];
  List<String> regions = [];
  List<String> cities = [];

  // Initialize the counts of countries, regions, and cities
  int countryCount = 0;
  int regionCount = 0;
  int cityCount = 0;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Container(
            child: Wrap(
              children: [
                // Country dropdown
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Country'),
                  trailing: buildDropdown('Country', countries, selectedCountry, (value) {
                    setState(() {
                      selectedCountry = value;
                      updateRegions();
                      selectedRegion = null;
                      updateCities();
                      selectedCity = null;
                      filterData();
                    });
                  }),
                ),
                // Region dropdown
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Region'),
                  trailing: buildDropdown('Region', regions, selectedRegion, (value) {
                    setState(() {
                      selectedRegion = value;
                      updateCities();
                      selectedCity = null;
                      filterData();
                    });
                  }),
                ),
                // City dropdown
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('City'),
                  trailing: buildDropdown('City', cities, selectedCity, (value) {
                    setState(() {
                      selectedCity = value;
                      filterData();
                    });
                  }),
                ),
                // rest of your options
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Description'),
                  trailing: Switch(
                    value: hasDescriptionFilter,
                    onChanged: (bool value) {
                      setState(() {
                        hasDescriptionFilter = value;
                        filterData();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Artist'),
                  trailing: Switch(
                    value: hasArtistFilter,
                    onChanged: (bool value) {
                      setState(() {
                        hasArtistFilter = value;
                        filterData();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Material'),
                  trailing: Switch(
                    value: hasMaterialFilter,
                    onChanged: (bool value) {
                      setState(() {
                        hasMaterialFilter = value;
                        filterData();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date Created'),
                  trailing: Switch(
                    value: dateCreatedFilter,
                    onChanged: (bool value) {
                      setState(() {
                        dateCreatedFilter = value;
                        filterData();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date Installed'),
                  trailing: Switch(
                    value: dateInstalledFilter,
                    onChanged: (bool value) {
                      setState(() {
                        dateInstalledFilter = value;
                        filterData();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }




  void updateRegions() {
    if (selectedCountry != null && selectedCountry != 'ALL') {
      regions = ['ALL'] + countryRegionCityData[selectedCountry]!.keys.toList(); // Add the 'ALL' option for regions
    } else {
      regions = [];
    }
  }

  void updateCities() {
    if (selectedRegion != null && selectedRegion != 'ALL') {
      cities = ['ALL'] + countryRegionCityData[selectedCountry]![selectedRegion]!; // Add the 'ALL' option for cities
    } else {
      cities = [];
    }
  }


  Future<List<PublicArt>> fetchDataFromObjectBox() async {
    List<PublicArt> data = db.getAllPublicArts(); // Get all PublicArt objects using the global 'db' variable

    Map<String, Map<String, List<String>>> locationData = {};

    for (PublicArt artPiece in data) {
      String country = artPiece.country;
      String region = artPiece.region;
      String city = artPiece.city;

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
    }

    // Update the countryRegionCityData map and refresh the UI
    setState(() {
      countryRegionCityData = locationData;
      countries = ['ALL'] + countryRegionCityData.keys.toList();
    });

    return data;
  }



  List<PublicArt> allArtPieces = [];
  List<PublicArt> filteredArtPieces = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromObjectBox().then((data) {
      setState(() {
        allArtPieces = data;
        countries = ['ALL'] + countryRegionCityData.keys.toList(); // Add the 'ALL' option for countries
        filterData();
        isLoading = false;
      });
    });
  }


  void filterData() {
    setState(() {
      filteredArtPieces = allArtPieces.where((artPiece) {
        return (selectedCountry == null ||
            selectedCountry == 'ALL' ||
            artPiece.country == selectedCountry) &&
            (selectedRegion == null ||
                selectedRegion == 'ALL' ||
                artPiece.region == selectedRegion) &&
            (selectedCity == null ||
                selectedCity == 'ALL' ||
                artPiece.city == selectedCity) &&
            (!hasDescriptionFilter || (artPiece.description?.isNotEmpty ?? false)) &&
            (!hasArtistFilter || (artPiece.artist?.isNotEmpty ?? false)) &&
            (!hasMaterialFilter || (artPiece.material?.isNotEmpty ?? false)) &&
            (!dateCreatedFilter || (artPiece.dateCreated?.isNotEmpty ?? false)) &&
            (!dateInstalledFilter || (artPiece.dateInstalled?.isNotEmpty ?? false));
      }).toList();

      // Update the country, region, and city counts
      countryCount =
          filteredArtPieces.map((artPiece) => artPiece.country).toSet().length;
      regionCount =
          filteredArtPieces.map((artPiece) => artPiece.region).toSet().length;
      cityCount =
          filteredArtPieces.map((artPiece) => artPiece.city).toSet().length;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Public Art'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown menus for country, region, and city filters
          // Add a Padding widget to display the number of filtered results
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${filteredArtPieces.length} result(s) found\n',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  TextSpan(
                    text:
                        'Countries: $countryCount, Regions: $regionCount, Cities: $cityCount',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // ListView to display filtered art pieces
          Expanded(
            child: ListView.builder(
              itemCount: filteredArtPieces.length,
              itemBuilder: (context, index) {
                final artPiece = filteredArtPieces[index];
                return ListTile(
                  // You can change this part to display the image using an image URL or another property.
                  leading: Image.asset(
                    'assets/images/icon.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(artPiece.name),
                  subtitle: Text(
                      '${artPiece.city}, ${artPiece.region}, ${artPiece.country}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(art: artPiece),
                      ),
                    );
                  },
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
