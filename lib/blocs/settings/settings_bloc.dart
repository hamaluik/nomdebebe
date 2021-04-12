import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:namekit/blocs/settings/settings_event.dart';
import 'package:namekit/blocs/settings/settings_state.dart';
import 'package:namekit/models/sex.dart';
import 'package:namekit/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc(this.settingsRepository) : super(SettingsState.initial());

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsLoad) {
      Sex? sex = settingsRepository.sex;
      List<String> firstLetters = settingsRepository.firstLetters;
      yield SettingsState(sex, HashSet.of(firstLetters));
    } else if (event is SettingsSetSex) {
      settingsRepository.sex = event.sex;
      yield SettingsState(event.sex, state.firstLetters);
    } else if (event is SettingsAddFirstLetter) {
      HashSet<String> letters = HashSet.from(state.firstLetters);
      letters.add(event.firstLetter.toUpperCase());
      settingsRepository.firstLetters = letters.toList();
      yield SettingsState(state.sexPreference, letters);
    } else if (event is SettingsRemoveFirstLetter) {
      HashSet<String> letters = HashSet.from(state.firstLetters);
      letters.remove(event.firstLetter);
      settingsRepository.firstLetters = letters.toList();
      yield SettingsState(state.sexPreference, letters);
    }
  }
}
