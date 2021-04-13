import 'package:flutter/material.dart';

enum Sex { male, female }

Color sexToColour(BuildContext context, Sex sex) {
  Brightness b = Theme.of(context).brightness;
  switch (sex) {
    case Sex.male:
      return b == Brightness.light
          ? Colors.blue.shade600
          : Colors.blue.shade900;
    case Sex.female:
      return b == Brightness.light
          ? Colors.pink.shade600
          : Colors.pink.shade900;
  }
}

Sex sexFromString(String s) {
  if (s.toUpperCase() == 'M') return Sex.male;
  return Sex.female;
}

String sexToString(Sex s) {
  if (s == Sex.male) return 'M';
  return 'F';
}
