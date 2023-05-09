import 'package:cloud_firestore/cloud_firestore.dart';
import './dummy_manifest.dart';


Future<void> uploadStandardizedDataToFirestore() async {
  // Get standardized data
  List<Map<String, dynamic>> standardizedData = await processPublicArtData();

  // Firestore reference
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the reference to the 'Items' collection
  // use 'Items' for in use db and 'Manifest_test' for testing menifest.
  CollectionReference itemsCollection = firestore.collection('Categories')
      .doc('Public_Art')
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

    if (querySnapshot.docs.isEmpty) {
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
