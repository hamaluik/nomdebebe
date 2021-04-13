import 'dart:async';
import 'package:namekit/models/nullable.dart';
import 'package:bloc/bloc.dart';
import 'package:namekit/blocs/names/names_event.dart';
import 'package:namekit/blocs/names/names_state.dart';
import 'package:namekit/blocs/settings/settings_bloc.dart';
import 'package:namekit/blocs/settings/settings_state.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/repositories/names_repository.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  final NamesRepository namesRepository;
  final SettingsBloc settings;
  StreamSubscription? settingsSubscription;
  //settings.stream.listen((SettingsState settings) {
  //print("settings stream updated in namesbloc");
  //this.add(NamesLoad());
  //});

  NamesBloc._(this.namesRepository, this.settings)
      : super(NamesState.initial());

  static NamesBloc load(
      NamesRepository namesRepository, SettingsBloc settings) {
    NamesBloc bloc = NamesBloc._(namesRepository, settings);
    bloc.settingsSubscription =
        bloc.settings.stream.listen((SettingsState settings) {
      print("settings stream updated in namesbloc");
      bloc.add(NamesLoad());
    });
    return bloc;
  }

  @override
  Future<void> close() {
    settingsSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);

      int totalNames =
          namesRepository.countTotalNames(filters: settings.state.filters);
      int undecidedNames =
          namesRepository.countUndecidedNames(filters: settings.state.filters);
      int likedNames =
          namesRepository.countLikedNames(filters: settings.state.filters);

      yield state.copyWith(
          nextUndecidedName: Nullable(undecided),
          namesCount: totalNames,
          undecidedNamesCount: undecidedNames,
          likedNamesCount: likedNames);
    } else if (event is NamesLike) {
      namesRepository.likeName(event.name);

      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);

      int totalNames =
          namesRepository.countTotalNames(filters: settings.state.filters);
      int undecidedNames =
          namesRepository.countUndecidedNames(filters: settings.state.filters);
      int likedNames =
          namesRepository.countLikedNames(filters: settings.state.filters);

      yield state.copyWith(
          nextUndecidedName: Nullable(undecided),
          namesCount: totalNames,
          undecidedNamesCount: undecidedNames,
          likedNamesCount: likedNames);
    } else if (event is NamesDislike) {
      namesRepository.dislikeName(event.name);

      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);

      int totalNames =
          namesRepository.countTotalNames(filters: settings.state.filters);
      int undecidedNames =
          namesRepository.countUndecidedNames(filters: settings.state.filters);
      int likedNames =
          namesRepository.countLikedNames(filters: settings.state.filters);

      yield state.copyWith(
          nextUndecidedName: Nullable(undecided),
          namesCount: totalNames,
          undecidedNamesCount: undecidedNames,
          likedNamesCount: likedNames);
    } else if (event is NamesUndecide) {
      namesRepository.undecideName(event.name);

      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);

      int totalNames =
          namesRepository.countTotalNames(filters: settings.state.filters);
      int undecidedNames =
          namesRepository.countUndecidedNames(filters: settings.state.filters);
      int likedNames =
          namesRepository.countLikedNames(filters: settings.state.filters);

      yield state.copyWith(
          nextUndecidedName: Nullable(undecided),
          namesCount: totalNames,
          undecidedNamesCount: undecidedNames,
          likedNamesCount: likedNames);
    }
  }
}
