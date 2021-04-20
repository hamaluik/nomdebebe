import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:nomdebebe/blocs/settings/settings_event.dart';
import 'package:nomdebebe/blocs/settings/settings_state.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/repositories/settings_repository.dart';
import 'package:nomdebebe/themes.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc(this.settingsRepository) : super(SettingsState.initial());

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsLoad) {
      Sex? sex = settingsRepository.sex;
      List<String> firstLetters = settingsRepository.firstLetters;
      ThemeType? theme = settingsRepository.theme;
      bool pinkAndBlue = settingsRepository.pinkAndBlue;
      List<int> decades = settingsRepository.decades;
      int? maxRank = settingsRepository.maxRank;
      yield SettingsState(sex, HashSet.of(firstLetters), theme, pinkAndBlue,
          HashSet.of(decades), maxRank);
    } else if (event is SettingsSetSex) {
      settingsRepository.sex = event.sex;
      yield SettingsState(event.sex, state.firstLetters, state.theme,
          state.pinkAndBlue, state.decades, state.maxRank);
    } else if (event is SettingsSetFirstLetters) {
      settingsRepository.firstLetters = event.firstLetters.toList();
      yield SettingsState(
        state.sexPreference,
        event.firstLetters,
        state.theme,
        state.pinkAndBlue,
        state.decades,
        state.maxRank,
      );
    } else if (event is SettingsSetTheme) {
      settingsRepository.theme = event.theme;
      yield SettingsState(state.sexPreference, state.firstLetters, event.theme,
          state.pinkAndBlue, state.decades, state.maxRank);
    } else if (event is SettingsFactoryReset) {
      settingsRepository.factoryReset();
      yield state;
      this.add(SettingsLoad());
    } else if (event is SettingsSetPinkAndBlue) {
      settingsRepository.pinkAndBlue = event.pinkAndBlue;
      yield SettingsState(state.sexPreference, state.firstLetters, state.theme,
          event.pinkAndBlue, state.decades, state.maxRank);
    } else if (event is SettingsSetDecades) {
      settingsRepository.decades = event.decades.toList();
      yield SettingsState(state.sexPreference, state.firstLetters, state.theme,
          state.pinkAndBlue, event.decades, event.maxRank);
    }
  }
}
