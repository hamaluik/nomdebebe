import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/themes.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoad extends SettingsEvent {}

class SettingsSetSex extends SettingsEvent {
  final Sex? sex;
  const SettingsSetSex(this.sex);

  @override
  List<Object?> get props => [sex];
}

class SettingsSetFirstLetters extends SettingsEvent {
  final HashSet<String> firstLetters;
  const SettingsSetFirstLetters(this.firstLetters);
  @override
  List<Object?> get props => [firstLetters];
}

class SettingsSetTheme extends SettingsEvent {
  final ThemeType? theme;
  const SettingsSetTheme(this.theme);
  @override
  List<Object?> get props => [theme];
}

class SettingsFactoryReset extends SettingsEvent {}

class SettingsSetPinkAndBlue extends SettingsEvent {
  final bool pinkAndBlue;
  const SettingsSetPinkAndBlue(this.pinkAndBlue);
  @override
  List<Object?> get props => [pinkAndBlue];
}

class SettingsSetDecades extends SettingsEvent {
  final HashSet<int> decades;
  final int? maxRank;
  const SettingsSetDecades(this.decades, this.maxRank);
  @override
  List<Object?> get props => [decades, maxRank];
}
