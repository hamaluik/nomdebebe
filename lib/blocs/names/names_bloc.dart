import 'package:bloc/bloc.dart';
import 'package:namekit/blocs/names/names_event.dart';
import 'package:namekit/blocs/names/names_state.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/repositories/names_repository.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  final NamesRepository namesRepository;

  NamesBloc(this.namesRepository) : super(NamesState.initial());

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      Name? undecided = namesRepository.getNextUndecidedName();
      yield NamesState(undecided);
    } else if (event is NamesLike) {
      namesRepository.likeName(event.name);
      Name? undecided = namesRepository.getNextUndecidedName();
      yield NamesState(undecided);
    } else if (event is NamesDislike) {
      namesRepository.dislikeName(event.name);
      Name? undecided = namesRepository.getNextUndecidedName();
      yield NamesState(undecided);
    } else if (event is NamesUndecide) {
      namesRepository.undecideName(event.name);
      Name? undecided = namesRepository.getNextUndecidedName();
      yield NamesState(undecided);
    }
  }
}
