import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> filterCalgary(dynamic data, String countryCode, String regionCode, String cityCode, bool stringify) async  {
  if (data is String) {
    data = jsonDecode(data);
  }

  List<dynamic> newData = [];

  for (var d in data) {
    Map<String, dynamic> item = {};

    // add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };


    item['name'] = d['title'];
    if (item['name'] == null) {
      print('Data name not found for art with url ${d['url']}');
    }
    Map<String, dynamic> coordinates = {
      'longitude': d['point']['coordinates'][0],
      'latitude': d['point']['coordinates'][1]
    };
    if (coordinates['longitude'] == null || coordinates['latitude'] == null) {
      print('Data coordinates not found for art with url ${d['url']}');
    }
    item['coordinates'] = coordinates;
    newData.add(item);
  }

/*  if (stringify) {
    return jsonEncode(newData);
  }*/

  return newData;
}

// seattle
Future<List<dynamic>> filterSeattle(dynamic data, String countryCode, String regionCode, String cityCode, bool stringify) async {
  if (data is String) {
    data = jsonDecode(data);
  }

  List<dynamic> newData = [];

  for (var d in data) {
    Map<String, dynamic> item = {};

    // add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };


    item['name'] = d['title'];
    if (item['name'] == null) {
      print('Data name not found for art with url ${d['url']}');
    }
    Map<String, dynamic> coordinates = {
      'longitude': d['longitude'],
      'latitude': d['latitude']
    };
    if (coordinates['longitude'] == null || coordinates['latitude'] == null) {
      print('Data coordinates not found for art with url ${d['url']}');
    }
    item['coordinates'] = coordinates;
    newData.add(item);
  }

/*  if (stringify) {
    return jsonEncode(newData);
  }*/

  return newData;
}


Future<List<dynamic>> filterHamilton(dynamic data, String countryCode, String regionCode, String cityCode, bool stringify) async {
  if (data is String) {
    data = jsonDecode(data);
  }

  // Extract the features from the input data
  List<dynamic> features = data['features'];

  List<dynamic> newData = [];

  for (var d in features) {
    Map<String, dynamic> item = {};

    // Extract the attributes for each feature
    Map<String, dynamic> attributes = d['attributes'];

    // add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };

    item['name'] = attributes['ARTWORK_TITLE'];
    if (item['name'] == null) {
      print('Data name not found for art with url ${attributes['url']}');
    }
    Map<String, dynamic> coordinates = {
      'longitude': attributes['LONGITUDE'],
      'latitude': attributes['LATITUDE']
    };
    if (coordinates['longitude'] == null || coordinates['latitude'] == null) {
      print('Data coordinates not found for art with url ${attributes['url']}');
    }
    item['coordinates'] = coordinates;
    newData.add(item);
  }

/*  if (stringify) {
    return jsonEncode(newData);
  }*/

  return newData;
}

Future<List<dynamic>> filterPrinceGeorge(dynamic data, String countryCode, String regionCode, String cityCode, bool stringify) async {
  if (data is String) {
    data = jsonDecode(data);
  }

  List<dynamic> newData = [];

  for (var d in data['features']) {
    Map<String, dynamic> item = {};

    // add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };

    item['name'] = d['properties']['Title'];
    if (item['name'] == null) {
      print('Data name not found for art with url ${d['url']}');
    }
    Map<String, dynamic> coordinates = {
      'longitude': d['geometry']['coordinates'][0],
      'latitude': d['geometry']['coordinates'][1]
    };
    if (coordinates['longitude'] == null || coordinates['latitude'] == null) {
      print('Data coordinates not found for art with url ${d['url']}');
    }
    item['coordinates'] = coordinates;
    newData.add(item);
  }


  return newData;
}

Future<List<Map<String, dynamic>>> processPublicArtData() async {
  // Read the dummyData.json file from assets/json folder
  String jsonString = await rootBundle.loadString('assets/json/dummyData.json');
  List<Map<String, dynamic>> elements = List<Map<String, dynamic>>.from(json.decode(jsonString));

  List<Map<String, dynamic>> standardizedDataList = [];

  if (elements == null || elements.isEmpty) {
    return standardizedDataList; // Return an empty list if there are no elements
  }

  // Process the data for each unique entry
  for (var element in elements) {
    if (element['labels']['category'] == 'public-art') {
      String countryCode = element['labels']['country'];
      String regionCode = element['labels']['region'];
      String cityCode = element['labels']['city'];

      // Get the raw data.
      String rawUrl = element['data']['datasets']['json']['url'];
      var response = await http.get(Uri.parse(rawUrl));
      if (response.statusCode == 200) {
        var rawData = json.decode(response.body);
        List<dynamic> filteredData;

        // Apply the Dart filter function (for different cities)

        if (countryCode == 'Canada' && regionCode == 'Alberta' &&
            cityCode == 'Calgary') {
          filteredData = await filterCalgary(
              rawData, countryCode, regionCode, cityCode, false);
        }

        else if (countryCode == 'Canada' && regionCode == 'Ontario' &&
            cityCode == 'Hamilton') {
          filteredData = await filterHamilton(
              rawData, countryCode, regionCode, cityCode, false);
        }

        else if (countryCode == 'Canada' && regionCode == 'British Columbia' &&
            cityCode == 'Prince George') {
          filteredData = await filterPrinceGeorge(
              rawData, countryCode, regionCode, cityCode, false);
        }

        // controlled list, only seattle is left.
        else {
          filteredData = await filterSeattle(
              rawData, countryCode, regionCode, cityCode, false);
        }

        // Loop through filteredData and add each item to standardizedDataList
        for (var item in filteredData) {
          standardizedDataList.add({
            'labels': {
              'country': countryCode,
              'region': regionCode,
              'city': cityCode,
            },
            'coordinates': item['coordinates'],
            'name': item['name'],
          });
        }
      } else {
        print("Failed to fetch raw data.");
        return []; // Return an empty list if the fetch fails
      }
    }
  }

  return standardizedDataList;
}


Future<void> uploadStandardizedDataToFirestore() async {
    // Get standardized data
    List<Map<String, dynamic>> standardizedData = await processPublicArtData();

    // Firestore reference
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the reference to the 'Items' collection
    // use 'Items' for in use db and 'Manifest_test' for testing menifest.
    CollectionReference itemsCollection = firestore.collection('Categories')
        .doc('Public_Art')
    //.collection('Items');
        .collection('Manifest_test');

    // Upload each element of standardizedData as its own document
    for (var item in standardizedData) {
      // Check for duplicates based on country, region, and city labels
      QuerySnapshot querySnapshot = await itemsCollection
          .where('labels.countryCode', isEqualTo: item['labels']['country'])
          .where('labels.regionCode', isEqualTo: item['labels']['region'])
          .where('labels.cityCode', isEqualTo: item['labels']['city'])
          .where('name', isEqualTo: item['name'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a duplicate is found, update the existing document
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'name': item['name'],
          'coordinates': item['coordinates']
        });
      } else {
        // If no duplicate is found, create a new document knowing public art schema from ODEN (simple)
        DocumentReference docRef = itemsCollection.doc();
        await docRef.set({
          'labels': {
            'countryCode': item['labels']['country'],
            'regionCode': item['labels']['region'],
            'cityCode': item['labels']['city'],
          },
          'name': item['name'],
          'coordinates': item['coordinates']
        });
      }
    }

    print('Data uploaded to Firestore successfully.');
  }
