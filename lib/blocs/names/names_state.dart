import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';

class NamesState extends Equatable {
  final Name? nextUndecidedName;
  const NamesState(this.nextUndecidedName);

  NamesState.initial() : nextUndecidedName = null;

  @override
  List<Object?> get props => [nextUndecidedName];
}
