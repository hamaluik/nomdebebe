import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:namekit/models/filter.dart';
import 'package:namekit/models/sex.dart';
import 'package:namekit/themes.dart';

class SettingsState extends Equatable {
  final Sex? sexPreference;
  final HashSet<String> firstLetters;
  final List<Filter> filters;
  final ThemeType? theme;
  final bool pinkAndBlue;

  static List<Filter> _buildFilters(Sex? sex, HashSet<String> letters) {
    List<Filter> filters = [];

    if (sex == Sex.male)
      filters.add(SexFilter.male);
    else if (sex == Sex.female) filters.add(SexFilter.female);

    if (letters.isNotEmpty) {
      filters.add(FirstLettersFilter(letters.toList()));
    }

    return filters;
  }

  SettingsState(
      this.sexPreference, this.firstLetters, this.theme, this.pinkAndBlue)
      : filters = _buildFilters(sexPreference, firstLetters);

  SettingsState.initial()
      : sexPreference = null,
        firstLetters = HashSet(),
        filters = List.empty(),
        theme = null,
        pinkAndBlue = true;

  @override
  List<Object?> get props => [sexPreference, firstLetters, theme, pinkAndBlue];
}
