import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nomdebebe/blocs/names/names.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/sex.dart';

class NamePair extends Equatable {
  final Name a;
  final Name b;

  NamePair(Name a, Name b)
      : this.a = a.id < b.id ? a : b,
        this.b = a.id > b.id ? a : b;

  @override
  List<Object> get props => [a, b];
}

class TournamentState extends Equatable {
  final HashMap<int, int> nameScores;
  final List<NamePair> pendingPairs;

  const TournamentState(this.nameScores, this.pendingPairs);

  @override
  List<Object> get props => [nameScores, pendingPairs];
}

class TournamentEvent extends Equatable {
  const TournamentEvent();
  @override
  List<Object?> get props => [];
}

class TournamentRank extends TournamentEvent {
  final NamePair names;
  final bool likedA;

  const TournamentRank(this.names, this.likedA);

  @override
  List<Object?> get props => [names, likedA];
}

class TournamentCommit extends TournamentEvent {}

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final NamesBloc namesBloc;

  TournamentBloc(this.namesBloc, List<NamePair> pendingPairs)
      : super(TournamentState(HashMap(), pendingPairs));

  static TournamentBloc load(NamesBloc namesBloc, Sex? sex) {
    List<NamePair> pairs = [];
    List<Name> names;
    if (sex != null)
      names =
          namesBloc.state.likedNames.where((Name n) => n.sex == sex).toList();
    else
      names = namesBloc.state.likedNames.toList();

    for (int i = 0; i < names.length; i++) {
      for (int j = (i + 1); j < names.length; j++) {
        pairs.add(NamePair(names[i], names[j]));
      }
    }
    print("${names.length} names; ${pairs.length} pairs");
    pairs.shuffle();

    return TournamentBloc(namesBloc, pairs);
  }

  @override
  Stream<TournamentState> mapEventToState(TournamentEvent event) async* {
    if (event is TournamentRank) {
      HashMap<int, int> nameScores = HashMap.from(state.nameScores);
      if (event.likedA)
        nameScores[event.names.a.id] = (nameScores[event.names.a.id] ?? 0) + 1;
      else
        nameScores[event.names.b.id] = (nameScores[event.names.b.id] ?? 0) + 1;

      List<NamePair> pendingPairs =
          state.pendingPairs.where((NamePair p) => p != event.names).toList();

      yield TournamentState(nameScores, pendingPairs);
    } else if (event is TournamentCommit) {
      List<int> ids = state.nameScores.keys.toList();
      ids.sort((a, b) => state.nameScores[b]!.compareTo(state.nameScores[a]!));

      await namesBloc.namesRepository.rankLikedNames(ids);
      namesBloc.add(NamesLoad());
    }
  }
}
