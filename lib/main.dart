import 'package:flutter/material.dart';
import './screens/home_page.dart';
import './theme/style.dart';

// ---------------------------- //
// ----- The main driver ------ //
// ---------------------------- //

void main() {
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
