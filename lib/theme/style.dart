import "package:flutter/material.dart";

// ----------------------------------------- //
// ----- All styles are contained here ----- //
// ----------------------------------------- //

ThemeData appTheme() {
  return ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: appBarTheme());
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
      iconTheme: IconThemeData(color: Color(0xFF000080)),
      actionsIconTheme: IconThemeData(color: Color(0xFF16BCD4)),
      backgroundColor: Colors.white);
}


// Dark Navy Blue: 0xFF2D3848
// Primary: 0xFF16BCD4
// #16BCD4