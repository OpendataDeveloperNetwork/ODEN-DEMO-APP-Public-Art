import 'package:flutter/material.dart';
import '../theme/style.dart';
import '../models/auth.dart';

///
/// This file is another app bar. But this contains a profile page
/// button. Choose this if you want to have a profile button on the app bar.
///

///
/// A function that creates the app bar widget.
///
AppBar profileAppBarWidget(BuildContext context, bool isCurrentPagePopped) {
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
        child: profileButton(context, isCurrentPagePopped),
      )
    ],
  );
}

///
/// A function that creates the profile button
/// with an inner function for navigation when clicked.
///
IconButton profileButton(BuildContext context, bool isCurrentPagePopped) {
  void navigateToProfile() {
    bool isLoggedIn = Auth().isLoggedIn;
    if (isCurrentPagePopped && isLoggedIn) {
      Navigator.pop(context);
    }
    Navigator.pushNamed(context, isLoggedIn ? '/profile' : '/login');
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
