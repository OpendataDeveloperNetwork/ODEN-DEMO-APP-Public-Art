import 'package:flutter/material.dart';
import '../theme/style.dart';

///
/// This app bar is used for the profile page or other
/// pages that needs a back button on the app bar. Please
/// choose this iff **you need a back button on the app bar**.
///

///
/// A function that creates the app bar widget.
///
AppBar backButtonAppBarWidget(BuildContext context) {
  return AppBar(
    backgroundColor: appBarTheme().backgroundColor,
    leading: backButton(context),
    title: Image.asset(
      ('assets/images/logo.jpg'),
      width: 125,
    ),
    centerTitle: true,
  );
}

///
/// A function that creates the profile button
/// with an inner function for navigation when clicked.
///
IconButton backButton(BuildContext context) {
  void navigate() {
    Navigator.pop(context);
  }

  return IconButton(
    splashColor: appBarTheme().actionsIconTheme?.color,
    icon: const Icon(
      Icons.keyboard_backspace,
      color: Color(0xFF666666),
    ),
    onPressed: navigate,
  );
}
