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
  final List<Name> names;
  final Name key;
  final int i;
  final int j;
  final NamePair? pendingPair;

  const TournamentState(this.names, this.key, this.i, this.j, this.pendingPair);

  @override
  List<Object?> get props => [names, key, i, j, pendingPair];
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

  TournamentBloc(this.namesBloc, List<Name> names)
      : super(TournamentState(
            names, names[1], 1, 0, NamePair(names[0], names[1])));

  static TournamentBloc load(NamesBloc namesBloc, Sex? sex) {
    List<Name> names;
    if (sex != null)
      names =
          namesBloc.state.likedNames.where((Name n) => n.sex == sex).toList();
    else
      names = namesBloc.state.likedNames.toList();

    return TournamentBloc(namesBloc, names);
  }

  @override
  Stream<TournamentState> mapEventToState(TournamentEvent event) async* {
    if (event is TournamentRank) {
      // clone things for the next state
      List<Name> names = state.names.toList();
      Name key = state.key;
      int i = state.i;
      int j = state.j;
      NamePair? pendingPair = null;

      // insertion sort, but using user interaction
      // for comparisons instead of the CPU, yielding
      // each time we need a comparison. Hence the muck

      // figure out arr[j] > key
      // keep it verbose so we can easily follow the logic
      bool aIsKey = event.names.a.id == state.key.id;
      bool keyIsLessThanArrJ = false;
      if (aIsKey) {
        // b is arr[j]
        keyIsLessThanArrJ = event.likedA;
      } else {
        // a is arr[j]
        // b is key
        keyIsLessThanArrJ = !event.likedA;
      }

      bool doneInnerLoop = false;
      if (keyIsLessThanArrJ) {
        names[j + 1] = names[j];
        j = j - 1;

        if (j < 0) {
          doneInnerLoop = true;
        }
      } else {
        doneInnerLoop = true;
      }

      if (doneInnerLoop) {
        names[j + 1] = key;
        i = i + 1;

        if (i <= (names.length - 1)) {
          // still have more to go
          key = names[i];
          j = i - 1;
          pendingPair = NamePair(names[j], key);
          yield TournamentState(names, key, i, j, pendingPair);
        } else {
          // all done!
          yield TournamentState(names, key, i, j, null);
        }
      } else {
        pendingPair = NamePair(names[j], key);
        yield TournamentState(names, key, i, j, pendingPair);
      }
    } else if (event is TournamentCommit) {
      List<int> ids = state.names.map((Name n) => n.id).toList();
      await namesBloc.namesRepository.rankLikedNames(ids);
      namesBloc.add(NamesLoad());
    }
  }
}
