import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';

class NamesState extends Equatable {
  final Name? nextUndecidedName;
  final List<Name> likedNames;
  final List<Name> dislikedNames;
  const NamesState(this.nextUndecidedName, this.likedNames, this.dislikedNames);

  NamesState.initial()
      : nextUndecidedName = null,
        likedNames = [],
        dislikedNames = [];

  @override
  List<Object?> get props => [nextUndecidedName, likedNames, dislikedNames];
}
