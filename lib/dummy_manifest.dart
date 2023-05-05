import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<void> processPublicArtData() async {
  // Read the dummyData.json file from assets/json folder
  String jsonString = await rootBundle.loadString('assets/json/dummyData.json');
  List<Map<String, dynamic>> elements = List<Map<String, dynamic>>.from(json.decode(jsonString));

  // Firestore reference
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Process and upload the data for each unique entry
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

          // Apply the Dart filter function
          var filteredData = filter(rawData, countryCode, regionCode, cityCode, false);

          // Upload the standardized data to Firestore
          await uploadStandardizedDataToFirestore(
              firestore, countryCode, regionCode, cityCode, filteredData);
        } else {
          print("Failed to fetch raw data.");
        }
    }
  }
}

Future<void> uploadStandardizedDataToFirestore(FirebaseFirestore firestore, String countryCode, String regionCode, String cityCode, List<dynamic> standardizedData) async {
  // Get the reference to the 'Items' collection
  CollectionReference itemsCollection = firestore.collection('Categories')
      .doc('Public_Art')
      .collection('Items');

  // Upload each element of standardizedData as its own document
  for (var item in standardizedData) {
    // Check for duplicates based on country, region, and city labels
    QuerySnapshot querySnapshot = await itemsCollection
        .where('labels.countryCode', isEqualTo: countryCode)
        .where('labels.regionCode', isEqualTo: regionCode)
        .where('labels.cityCode', isEqualTo: cityCode)
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
      // If no duplicate is found, create a new document
      DocumentReference docRef = itemsCollection.doc();
      await docRef.set({
        'labels': {
          'countryCode': countryCode,
          'regionCode': regionCode,
          'cityCode': cityCode,
        },
        'name': item['name'],
        'coordinates': item['coordinates']
      });
    }
  }

  print('Data uploaded to Firestore successfully.');
}



// Manual way

List<dynamic> filter(dynamic data, String countryCode, String regionCode, String cityCode, bool stringify) {
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
