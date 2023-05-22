import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oden_app/screens/profile_page.dart';
import 'package:oden_app/transmogrifier.dart' as transmogrifier;
import './screens/home_page.dart';
import './screens/map_page.dart';
import 'package:firebase_core/firebase_core.dart';
import './theme/style.dart';
import 'models/store.dart';
import 'screens/collections.dart';
import 'screens/login.dart';
import 'screens/sign_up.dart';
import 'screens/details.dart';

// ---------------------------- //
// ----- The main driver ------ //
// ---------------------------- //
late ObjectBoxDatabase db;

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  db = await ObjectBoxDatabase.create();
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
