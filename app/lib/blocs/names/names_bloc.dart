import 'dart:async';
import 'package:nomdebebe/models/filter.dart';
import 'package:nomdebebe/models/nullable.dart';
import 'package:bloc/bloc.dart';
import 'package:nomdebebe/blocs/names/names_event.dart';
import 'package:nomdebebe/blocs/names/names_state.dart';
import 'package:nomdebebe/blocs/settings/settings_bloc.dart';
import 'package:nomdebebe/blocs/settings/settings_state.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';
import 'package:nomdebebe/repositories/names_repository.dart';

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
      bloc.add(NamesLoad());
    });
    return bloc;
  }

  @override
  Future<void> close() {
    settingsSubscription?.cancel();
    return super.close();
  }

  NamesState _updateAll() {
    Name? undecided =
        namesRepository.getNextUndecidedName(filters: settings.state.filters);
    List<Name> likedNames =
        namesRepository.getRankedLikedNames(filters: settings.state.filters);

    int totalNames =
        namesRepository.countTotalNames(filters: settings.state.filters);
    int undecidedNames =
        namesRepository.countUndecidedNames(filters: settings.state.filters);
    int likedNamesCount =
        namesRepository.countLikedNames(filters: settings.state.filters);

    return state.copyWith(
        nextUndecidedName: Nullable(undecided),
        likedNames: likedNames,
        namesCount: totalNames,
        undecidedNamesCount: undecidedNames,
        likedNamesCount: likedNamesCount);
  }

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      yield _updateAll();
    } else if (event is NamesLike) {
      namesRepository.likeName(event.name);
      yield _updateAll();
    } else if (event is NamesDislike) {
      namesRepository.dislikeName(event.name);
      yield _updateAll();
    } else if (event is NamesUndecide) {
      namesRepository.undecideName(event.name);
      yield _updateAll();
    } else if (event is NamesLikedRank) {
      List<Filter> sexFilter = [];
      if (event.sex == Sex.male)
        sexFilter = [SexFilter.male];
      else if (event.sex == Sex.female) sexFilter = [SexFilter.female];

      namesRepository.swapLikedNamesRanks(event.oldRank, event.newRank,
          filters: settings.state.filters + sexFilter);
      List<Name> newLikedNames =
          namesRepository.getRankedLikedNames(filters: settings.state.filters);
      yield state.copyWith(likedNames: newLikedNames);
    } else if (event is NamesFactoryReset) {
      namesRepository.factoryReset();
      yield _updateAll();
    }
  }
}
