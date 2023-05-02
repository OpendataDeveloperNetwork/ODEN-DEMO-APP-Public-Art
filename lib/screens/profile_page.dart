import 'package:flutter/material.dart';
import 'package:oden_app/components/back_button_app_bar.dart';

// ------------------------ //
// ----- Profile Page ----- //
// ------------------------ //

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  // Leave the appBar null, for now, I will be creating a appBar class for that! - Joushua //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: backButtonAppBarWidget(context), body: Text("Profile"));
  }
}
