import 'package:flutter/material.dart';

enum Sex { male, female }

Color sexToColour(Sex sex) {
  switch (sex) {
    case Sex.male:
      return Colors.blue.shade600;
    case Sex.female:
      return Colors.pink.shade600;
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
