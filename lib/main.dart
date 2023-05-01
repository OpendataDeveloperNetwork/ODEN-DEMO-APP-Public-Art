import 'package:flutter/material.dart';
import './screens/home_page.dart';
import './screens/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // For simplicity, for now, just add your class on the home!
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ODEN Demo',
      home: MapsPage(),
    );
  }
}
