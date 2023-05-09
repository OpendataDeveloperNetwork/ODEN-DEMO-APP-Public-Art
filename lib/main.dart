import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oden_app/screens/profile_page.dart';
import './screens/home_page.dart';
import './screens/map_page.dart';
import 'package:firebase_core/firebase_core.dart';
import './theme/style.dart';
import 'screens/collections.dart';
import 'screens/login.dart';
import 'screens/sign_up.dart';
import 'screens/details.dart';

// import path to dummy_manifest.dart
import './oden_integration.dart';

// ---------------------------- //
// ----- The main driver ------ //
// ---------------------------- //

Future<void> main() async {
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
  //uploadStandardizedDataToFirestore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // For simplicity, for now, just add your class on the home!
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/profile': (context) => const ProfilePage(),
        '/homepage': (context) => const HomePage(),
        '/collections': (context) => const CollectionsPage(),
        '/maps': (context) => const MapsPage(),
      },
      title: 'ODEN Demo',
      theme: appTheme(),
      home: const HomePage(),
    );
  }
}
