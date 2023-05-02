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

///
/// A function that creates the profile button
/// with an inner function for navigation when clicked.
///
IconButton profileButton(BuildContext context) {
  return IconButton(
    splashColor: appBarTheme().actionsIconTheme?.color,
    icon: Icon(
      Icons.account_circle_rounded,
      color: appBarTheme().iconTheme?.color,
    ),
    onPressed: () => {},
  );
}
