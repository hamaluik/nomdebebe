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
      List<Name> likedNames =
          namesRepository.getNames(true, skip: 0, count: 20);
      List<Name> dislikedNames =
          namesRepository.getNames(false, skip: 0, count: 20);

      yield NamesState(undecided, likedNames, dislikedNames);
    } else if (event is NamesLike) {
      namesRepository.likeName(event.name);

      Name? undecided = namesRepository.getNextUndecidedName();
      List<Name> likedNames =
          namesRepository.getNames(true, skip: 0, count: 20);
      List<Name> dislikedNames =
          namesRepository.getNames(false, skip: 0, count: 20);

      yield NamesState(undecided, likedNames, dislikedNames);
    } else if (event is NamesDislike) {
      namesRepository.dislikeName(event.name);

      Name? undecided = namesRepository.getNextUndecidedName();
      List<Name> likedNames =
          namesRepository.getNames(true, skip: 0, count: 20);
      List<Name> dislikedNames =
          namesRepository.getNames(false, skip: 0, count: 20);

      yield NamesState(undecided, likedNames, dislikedNames);
    } else if (event is NamesUndecide) {
      namesRepository.undecideName(event.name);

      Name? undecided = namesRepository.getNextUndecidedName();
      List<Name> likedNames =
          namesRepository.getNames(true, skip: 0, count: 20);
      List<Name> dislikedNames =
          namesRepository.getNames(false, skip: 0, count: 20);

      yield NamesState(undecided, likedNames, dislikedNames);
    }
  }
}
