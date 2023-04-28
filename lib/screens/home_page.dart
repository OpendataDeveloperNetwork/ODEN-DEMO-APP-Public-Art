import 'package:flutter/material.dart';
import '../components/app_bar.dart';

// ------------------------ //
// ----- Landing Page ----- //
// ------------------------ //

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar());
  }
}
