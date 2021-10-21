import 'package:flutter/material.dart';

class IgniteTheme {
  static ThemeData get darkTheme {
    return ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        colorScheme:
            darkTheme.colorScheme.copyWith(secondary: Colors.orangeAccent),
        // fontFamily: 'Montserrat',
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: Colors.red,
        ));
  }
}
