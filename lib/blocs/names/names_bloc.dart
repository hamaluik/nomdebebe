import 'dart:async';

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
  late StreamSubscription settingsSubscription =
      settings.stream.listen((SettingsState settings) {
    this.add(NamesLoad());
  });

  NamesBloc(this.namesRepository, this.settings) : super(NamesState.initial());

  @override
  Future<void> close() {
    settingsSubscription.cancel();
    return super.close();
  }

  @override
  Stream<NamesState> mapEventToState(NamesEvent event) async* {
    if (event is NamesLoad) {
      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);
      yield NamesState(undecided);
    } else if (event is NamesLike) {
      namesRepository.likeName(event.name);
      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);
      yield NamesState(undecided);
    } else if (event is NamesDislike) {
      namesRepository.dislikeName(event.name);
      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);
      yield NamesState(undecided);
    } else if (event is NamesUndecide) {
      namesRepository.undecideName(event.name);
      Name? undecided =
          namesRepository.getNextUndecidedName(filters: settings.state.filters);
      yield NamesState(undecided);
    }
  }
}
