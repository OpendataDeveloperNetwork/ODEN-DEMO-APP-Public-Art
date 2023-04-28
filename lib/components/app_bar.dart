import 'package:flutter/material.dart';
import '../theme/style.dart';

AppBar appBar() {
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
        child: profileButton(),
      )
    ],
  );
}

IconButton profileButton() {
  return IconButton(
    splashColor: appBarTheme().actionsIconTheme?.color,
    icon: Icon(
      Icons.account_circle_rounded,
      color: appBarTheme().iconTheme?.color,
    ),
    onPressed: () => {},
  );
}
