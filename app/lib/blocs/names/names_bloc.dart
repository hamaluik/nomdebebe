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
      List<Name> liked = state.likedNames.toList() + [event.name.makeLiked()];

      // add it to our undo history
      List<DecisionNode> decisionHistory = state.decisionHistory.toList();
      decisionHistory.add(DecisionNode(event.name, DecisionType.Liked));
      // cap the decision history at 200 names, arbitrarily
      if (decisionHistory.length > 200) {
        decisionHistory.removeAt(0);
      }

      // return the new state immediately so we can update the UI
      yield state.copyWith(
        undecidedNameBuffer: undecided,
        undecidedNamesCount: state.undecidedNamesCount - 1,
        likedNames: liked,
        likedNamesCount: state.likedNamesCount + 1,
        decisionHistory: decisionHistory,
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

      // add it to our undo history
      List<DecisionNode> decisionHistory = state.decisionHistory.toList();
      decisionHistory.add(DecisionNode(event.name, DecisionType.Disliked));
      // cap the decision history at 200 names, arbitrarily
      if (decisionHistory.length > 200) {
        decisionHistory.removeAt(0);
      }

      // remove it from the liked list if its there
      List<Name> liked =
          state.likedNames.where((Name n) => n.id != event.name.id).toList();

      yield state.copyWith(
        undecidedNameBuffer: undecided,
        undecidedNamesCount: state.undecidedNamesCount - 1,
        decisionHistory: decisionHistory,
        likedNames: liked,
        likedNamesCount: liked.length,
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
      // process the swap locally so we don't have to wait for the database to update the UI
      if (event.sex == null) {
        List<Name> likedNames = state.likedNames.toList();
        Name name = likedNames.removeAt(event.oldRank);
        likedNames.insert(
            event.newRank > event.oldRank ? event.newRank - 1 : event.newRank,
            name);
        yield state.copyWith(likedNames: likedNames);
      } else {
        // separate out the sexes
        List<Name> currentLiked =
            state.likedNames.where((Name n) => n.sex == event.sex).toList();
        List<Name> otherLiked =
            state.likedNames.where((Name n) => n.sex != event.sex).toList();

        Name name = currentLiked.removeAt(event.oldRank);
        currentLiked.insert(
            event.newRank > event.oldRank ? event.newRank - 1 : event.newRank,
            name);

        List<Name> liked = currentLiked + otherLiked;
        yield state.copyWith(likedNames: liked);
      }

      // now update the database, this should be invisible to the user
      // as we've already processed the swap from the UI for the UI above
      List<Filter> sexFilter = [];
      if (event.sex == Sex.male)
        sexFilter = [SexFilter.male];
      else if (event.sex == Sex.female) sexFilter = [SexFilter.female];
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
    } else if (event is NamesUndoDecision) {
      if (state.decisionHistory.isNotEmpty) {
        // pop the most recent name off the stack
        List<DecisionNode> decisionHistory = state.decisionHistory.toList();
        DecisionNode decision = decisionHistory.removeLast();

        switch (decision.type) {
          case DecisionType.Liked:
            {
              // undecide the name immediately
              Name name = decision.name;
              var undecide = namesRepository.undecideName(name);

              // remove it from our liked names
              List<Name> likedNames =
                  state.likedNames.where((Name n) => n.id != name.id).toList();
              int likedCount = state.likedNamesCount - 1;
              int undecidedCount = state.undecidedNamesCount + 1;
              List<Name> undecidedNames = state.undecidedNameBuffer.toList();
              undecidedNames.insert(0, name);

              // yield the updated state immediately so we don't interrupt the UI
              yield state.copyWith(
                  undecidedNameBuffer: undecidedNames,
                  likedNames: likedNames,
                  undecidedNamesCount: undecidedCount,
                  likedNamesCount: likedCount,
                  decisionHistory: decisionHistory);

              // finally, make sure the database is updated
              await undecide;
            }
            break;
          case DecisionType.Disliked:
            {
              // undecide the name immediately
              Name name = decision.name;
              var undecide = namesRepository.undecideName(name);
              int undecidedCount = state.undecidedNamesCount + 1;
              List<Name> undecidedNames = state.undecidedNameBuffer.toList();
              undecidedNames.insert(0, name);

              // yield the updated state immediately so we don't interrupt the UI
              yield state.copyWith(
                  undecidedNameBuffer: undecidedNames,
                  undecidedNamesCount: undecidedCount,
                  decisionHistory: decisionHistory);

              // finally, make sure the database is updated
              await undecide;
            }
            break;
        }
      }
    }
  }
}
