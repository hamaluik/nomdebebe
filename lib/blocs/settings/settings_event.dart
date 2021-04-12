import 'package:equatable/equatable.dart';
import 'package:namekit/models/sex.dart';

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

class SettingsAddFirstLetter extends SettingsEvent {
  final String firstLetter;
  const SettingsAddFirstLetter(this.firstLetter);

  @override
  List<Object?> get props => [firstLetter];
}

class SettingsRemoveFirstLetter extends SettingsEvent {
  final String firstLetter;
  const SettingsRemoveFirstLetter(this.firstLetter);

  @override
  List<Object?> get props => [firstLetter];
}
