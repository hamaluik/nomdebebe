import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/themes.dart';

class SettingsState extends Equatable {
  final Sex? sexPreference;
  final HashSet<String> firstLetters;
  final HashSet<int> decades;
  final int? maxRank;
  final List<Filter> filters;
  final ThemeType? theme;
  final bool pinkAndBlue;
  final String server;

  static List<Filter> _buildFilters(
      Sex? sex, HashSet<String> letters, HashSet<int> decades, int? maxRank) {
    List<Filter> filters = [];

    if (sex == Sex.male)
      filters.add(SexFilter.male);
    else if (sex == Sex.female) filters.add(SexFilter.female);

    if (letters.isNotEmpty) {
      filters.add(FirstLettersFilter(letters.toList()));
    }

    if (decades.isNotEmpty) {
      filters.add(DecadesFilter(decades.toList(), maxRank));
    }

    return filters;
  }

  SettingsState(this.sexPreference, this.firstLetters, this.theme,
      this.pinkAndBlue, this.decades, this.maxRank, this.server)
      : filters = _buildFilters(sexPreference, firstLetters, decades, maxRank);

  SettingsState.initial()
      : sexPreference = null,
        firstLetters = HashSet(),
        filters = List.empty(),
        theme = null,
        pinkAndBlue = true,
        decades = HashSet(),
        maxRank = 1000,
        server = "https://nomdebebe.hamaluik.dev";

  @override
  List<Object?> get props => [
        sexPreference,
        firstLetters,
        theme,
        pinkAndBlue,
        decades,
        maxRank,
        server
      ];
}
