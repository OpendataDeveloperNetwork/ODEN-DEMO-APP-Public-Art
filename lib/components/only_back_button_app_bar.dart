import 'package:flutter/material.dart';
import '../theme/style.dart';

///
/// This app bar is use for the login/signUp page or other
/// pages that only needs a back button, *no logo*. Please
/// choose this iff **you need a back button on the app bar with no logo**.
///

///
/// A function that creates the app bar widget.
///
AppBar backButtonAppBarWidget(BuildContext context) {
  return AppBar(
    backgroundColor: appBarTheme().backgroundColor,
    leading: backButton(context),
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
