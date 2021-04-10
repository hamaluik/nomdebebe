import 'package:bloc/bloc.dart';
import 'package:namekit/blocs/names/names_event.dart';
import 'package:namekit/blocs/names/names_state.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/repositories/names_repository.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  final NamesRepository namesRepository;

  NamesBloc(this.namesRepository) : super(NamesState(List.empty()));

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      yield NamesState(namesRepository.getAllNames());
    } else if (event is NamesLike) {
      Name name = namesRepository.likeName(event.name);
      List<Name> names = state.names.map((Name n) {
        if (n.id == name.id) {
          return name;
        }
        return n;
      }).toList();
      yield NamesState(names);
    } else if (event is NamesDislike) {
      Name name = namesRepository.dislikeName(event.name);
      List<Name> names = state.names.map((Name n) {
        if (n.id == name.id) {
          return name;
        }
        return n;
      }).toList();
      yield NamesState(names);
    } else if (event is NamesUndecide) {
      Name name = namesRepository.undecideName(event.name);
      List<Name> names = state.names.map((Name n) {
        if (n.id == name.id) {
          return name;
        }
        return n;
      }).toList();
      yield NamesState(names);
    }
  }
}
