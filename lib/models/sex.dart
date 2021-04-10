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
