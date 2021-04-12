import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:namekit/models/filter.dart';
import 'package:namekit/models/sex.dart';

class SettingsState extends Equatable {
  final Sex? sexPreference;
  final HashSet<String> firstLetters;
  final List<Filter> filters;

  static List<Filter> _buildFilters(Sex? sex, HashSet<String> letters) {
    List<Filter> filters = List.empty();

    if (sex == Sex.male)
      filters.add(SexFilter.male);
    else if (sex == Sex.female) filters.add(SexFilter.female);

    if (letters.isNotEmpty) {
      filters.add(FirstLettersFilter(letters.toList()));
    }

    return filters;
  }

  SettingsState(this.sexPreference, this.firstLetters)
      : filters = _buildFilters(sexPreference, firstLetters);

  SettingsState.initial()
      : sexPreference = null,
        firstLetters = HashSet(),
        filters = List.empty();

  @override
  List<Object?> get props => [sexPreference, firstLetters];
}
