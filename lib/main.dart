import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './screens/home_page.dart';
import './screens/map_page.dart';
import 'package:firebase_core/firebase_core.dart';
import './theme/style.dart';

// import path to dummy_manifest.dart
import './dummy_manifest.dart';

// ---------------------------- //
// ----- The main driver ------ //
// ---------------------------- //

Future<void> main() async{
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Following function runs the dummy minefest.dart
  // will upload all entries to the firestore.
  // commented out not run run everytime.
  //processPublicArtData();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // For simplicity, for now, just add your class on the home!
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ODEN Demo',
      theme: appTheme(),
      home: const HomePage(),
    );
  }
}
