import "package:flutter/material.dart";

ThemeData appTheme() {
  return ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: appBarTheme());
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
      iconTheme: IconThemeData(color: Color(0xFF2D3848)),
      actionsIconTheme: IconThemeData(color: Color(0xFF77BF4B)),
      backgroundColor: Colors.white);
}


// Dark Navy Blue: 0xFF2D3848
// Lime: 0xFF77BF4B
// 