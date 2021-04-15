import 'package:flutter/material.dart';

enum ThemeType { light, dark, black }

ThemeData? themeForType(ThemeType? type) {
  switch (type) {
    case null:
      return null;
    case ThemeType.light:
      return lightTheme;
    case ThemeType.dark:
      return darkTheme;
    case ThemeType.black:
      return blackTheme;
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.amber,
  primaryColor: Colors.amber[400],
  primaryColorBrightness: Brightness.light,
  accentColor: Colors.grey[900],
  accentColorBrightness: Brightness.dark,
  fontFamily: 'PublicSans',
  scaffoldBackgroundColor: Colors.amber[400],
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.amber,
  primaryColor: Colors.amber[400],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.grey[900],
  accentColorBrightness: Brightness.dark,
  fontFamily: 'PublicSans',
  scaffoldBackgroundColor: Colors.grey[800],
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.grey[850],
  ),
);

final ThemeData blackTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.amber,
  primaryColor: Colors.amber[400],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.amber[400],
  accentColorBrightness: Brightness.light,
  fontFamily: 'PublicSans',
  scaffoldBackgroundColor: Colors.black,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black,
  ),
);
