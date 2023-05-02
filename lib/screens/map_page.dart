import 'package:flutter/material.dart';
import 'package:oden_app/components/profile_button_app_bar.dart';

// ------------------------------------- //
// ----- Maps Page - Main Feature ------ //
// ------------------------------------- //

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});
  // Leave the appBar null, for now, I will be creating a appBar class for that! - Joushua //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBarWidget(context),
      body: const Text("Maps"),
    );
  }
}
