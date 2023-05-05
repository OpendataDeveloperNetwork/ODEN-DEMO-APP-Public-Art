import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<void> processPublicArtData() async {
  // Read the dummyData.json file from assets/json folder
  String jsonString = await rootBundle.loadString('assets/json/dummyData.json');
  List<Map<String, dynamic>> elements = List<Map<String, dynamic>>.from(json.decode(jsonString));

  // Initialize Firebase if you haven't done it already
  // await Firebase.initializeApp();

  // Firestore reference
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Process and upload the data for each unique entry
  for (var element in elements) {
    if (element['labels']['category'] == 'public-art') {
      String countryCode = element['labels']['country'];
      String regionCode = element['labels']['region'];
      String cityCode = element['labels']['city'];

      // Check if the combination of country, region, and city is unique
      if (await isNewLocation(firestore, countryCode, regionCode, cityCode)) {
        String rawUrl = element['data']['datasets']['json']['url'];
        var response = await http.get(Uri.parse(rawUrl));
        if (response.statusCode == 200) {
          var rawData = json.decode(response.body);

          // Apply the filter and standardize the data
          var standardizedData = standardizeData(rawData);

          // Upload the standardized data to Firestore
          await uploadStandardizedDataToFirestore(
              firestore, countryCode, regionCode, cityCode, standardizedData);
        } else {
          print("Failed to fetch raw data.");
        }
      }
    }
  }
}

Future<bool> isNewLocation(FirebaseFirestore firestore, String countryCode, String regionCode, String cityCode) async {
  // Check if the document already exists in Firestore
  DocumentSnapshot doc = await firestore.collection('Categories')
      .doc('Public_Art')
      .collection('Items')
      .doc('${countryCode}_${regionCode}_${cityCode}')
      .get();
  return !doc.exists;
}

List<Map<String, dynamic>> standardizeData(List<dynamic> rawData) {
  // Apply your data transformation and standardization logic here
  // This is a dummy example; replace this with your actual logic
  return rawData.map((item) => {
    'name': item['name'],
    'longitude': item['longitude'],
    'latitude': item['latitude'],
  }).toList();
}

Future<void> uploadStandardizedDataToFirestore(FirebaseFirestore firestore, String countryCode, String regionCode, String cityCode, List<Map<String, dynamic>> standardizedData) async {
  // Upload the data to Firestore
  await firestore.collection('Categories')
      .doc('Public_Art')
      .collection('Items')
      .doc('${countryCode}_${regionCode}_${cityCode}')
      .set({'data': standardizedData});

  print('Data uploaded to Firestore successfully.');
}