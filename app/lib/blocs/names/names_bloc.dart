import 'dart:async';
import 'package:nomdebebe/models/filter.dart';
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

  NamesBloc._(this.namesRepository, this.settings)
      : super(NamesState.initial());

  static NamesBloc load(
      NamesRepository namesRepository, SettingsBloc settings) {
    NamesBloc bloc = NamesBloc._(namesRepository, settings);
    bloc.settingsSubscription =
        bloc.settings.stream.listen((SettingsState settings) {
      print("reloading names due to settings change");
      bloc.add(NamesLoad());
    });
    return bloc;
  }

  @override
  Future<void> close() {
    settingsSubscription?.cancel();
    return super.close();
  }

  Future<NamesState> _updateAll() async {
    List<Name> undecided = await namesRepository.getNames(
        filters: settings.state.filters + [LikeFilter.undecided], count: 10);
    List<Name> likedNames = await namesRepository.getRankedLikedNames(
        filters: settings.state.filters);

    int totalNames =
        await namesRepository.countTotalNames(filters: settings.state.filters);
    int undecidedNames = await namesRepository.countUndecidedNames(
        filters: settings.state.filters);
    int likedNamesCount =
        await namesRepository.countLikedNames(filters: settings.state.filters);

    return state.copyWith(
        undecidedNameBuffer: undecided,
        likedNames: likedNames,
        namesCount: totalNames,
        undecidedNamesCount: undecidedNames,
        likedNamesCount: likedNamesCount);
  }

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      yield await _updateAll();
    } else if (event is NamesLike) {
      // like the name immediately
      var like = namesRepository.likeName(event.name);

      // remove it from our undecided buffer
      List<Name> undecided = state.undecidedNameBuffer
          .where((Name n) => n.id != event.name.id)
          .toList();
      List<Name> liked = state.likedNames.toList() + [event.name];

      // return the new state immediately so we can update the UI
      yield state.copyWith(
        undecidedNameBuffer: undecided,
        undecidedNamesCount: state.undecidedNamesCount - 1,
        likedNames: liked,
        likedNamesCount: state.likedNamesCount + 1,
      );

      // if we're running low on undecided names in our buffer, update the list
      // if all goes well, this will be invisible to the user
      if (undecided.length < 5) {
        await like;
        yield await Future.wait([
          namesRepository.getNames(
              filters: settings.state.filters + [LikeFilter.undecided],
              count: 10),
          namesRepository.countUndecidedNames(filters: settings.state.filters)
        ]).then((args) {
          List<Name> undecided = args[0] as List<Name>;
          int count = args[1] as int;
          return state.copyWith(
            undecidedNameBuffer: undecided,
            undecidedNamesCount: count,
          );
        });
      }
    } else if (event is NamesDislike) {
      // same deal as liking a name
      var dislike = namesRepository.dislikeName(event.name);

      List<Name> undecided = state.undecidedNameBuffer
          .where((Name n) => n.id != event.name.id)
          .toList();

      yield state.copyWith(
        undecidedNameBuffer: undecided,
        undecidedNamesCount: state.undecidedNamesCount - 1,
      );

      if (undecided.length < 5) {
        await dislike;
        yield await Future.wait([
          namesRepository.getNames(
              filters: settings.state.filters + [LikeFilter.undecided],
              count: 10),
          namesRepository.countUndecidedNames(filters: settings.state.filters)
        ]).then((args) {
          List<Name> undecided = args[0] as List<Name>;
          int count = args[1] as int;
          return state.copyWith(
            undecidedNameBuffer: undecided,
            undecidedNamesCount: count,
          );
        });
      }
    } else if (event is NamesUndecide) {
      // undeciding a name doesn't really happen on a critical path on the UI
      // so its ok if theres a slight lag here, so don't faff about as in the liking
      // and disliking areas
      await namesRepository.undecideName(event.name);
      yield await _updateAll();
    } else if (event is NamesLikedRank) {
      List<Filter> sexFilter = [];
      if (event.sex == Sex.male)
        sexFilter = [SexFilter.male];
      else if (event.sex == Sex.female) sexFilter = [SexFilter.female];

      // TODO: process the swap locally while dealing with name sexes
      // so that we don't lag the UI
      await namesRepository.swapLikedNamesRanks(event.oldRank, event.newRank,
          filters: settings.state.filters + sexFilter);
      List<Name> newLikedNames = await namesRepository.getRankedLikedNames(
          filters: settings.state.filters);

      // update the state
      yield state.copyWith(likedNames: newLikedNames);
    } else if (event is NamesFactoryReset) {
      // it's ok if this rare event takes a couple milliseconds of lag
      await namesRepository.factoryReset();
      yield await _updateAll();
    }
  }
}
