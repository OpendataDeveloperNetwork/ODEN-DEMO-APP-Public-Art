import 'package:flutter/material.dart';
import 'package:oden_app/screens/profile_page.dart';
import '../theme/style.dart';

AppBar appBar(BuildContext context) {
  return AppBar(
    backgroundColor: appBarTheme().backgroundColor,
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Image.asset(
        ('assets/images/logo.png'),
      ),
    ),
    leadingWidth: 125,
    toolbarHeight: 60,
    actions: [
      Transform.scale(
        scale: 1.75,
        child: profileButton(context),
      )
    ],
  );
}

IconButton profileButton(BuildContext context) {
  void navigateToProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  return IconButton(
    splashColor: appBarTheme().actionsIconTheme?.color,
    icon: Icon(
      Icons.account_circle_rounded,
      color: appBarTheme().iconTheme?.color,
    ),
    onPressed: navigateToProfile,
  );
}
