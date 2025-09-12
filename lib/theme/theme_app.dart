import 'package:flutter/material.dart';

class ThemeApp {
  static ThemeData theme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 3),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
  );
}
