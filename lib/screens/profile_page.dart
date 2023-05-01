import 'package:flutter/material.dart';
import 'package:oden_app/components/app_bar.dart';

// ------------------------ //
// ----- Profile Page ----- //
// ------------------------ //

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  // Leave the appBar null, for now, I will be creating a appBar class for that! - Joushua //
  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: null, body: Text("Profile"));
  }
}
