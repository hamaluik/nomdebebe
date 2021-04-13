import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/models/nullable.dart';

class NamesState extends Equatable {
  final Name? nextUndecidedName;
  final List<Name> likedNames;
  final int namesCount;
  final int undecidedNamesCount;
  final int likedNamesCount;

  const NamesState(this.nextUndecidedName, this.likedNames, this.namesCount,
      this.undecidedNamesCount, this.likedNamesCount);

  NamesState.initial()
      : nextUndecidedName = null,
        likedNames = [],
        namesCount = 0,
        undecidedNamesCount = 0,
        likedNamesCount = 0;

  @override
  List<Object?> get props => [
        nextUndecidedName,
        likedNames,
        namesCount,
        undecidedNamesCount,
        likedNamesCount
      ];

  NamesState copyWith({
    Nullable<Name?>? nextUndecidedName,
    List<Name>? likedNames,
    int? namesCount,
    int? undecidedNamesCount,
    int? likedNamesCount,
  }) =>
      NamesState(
        nextUndecidedName == null
            ? this.nextUndecidedName
            : nextUndecidedName.value,
        likedNames ?? this.likedNames,
        namesCount ?? this.namesCount,
        undecidedNamesCount ?? this.undecidedNamesCount,
        likedNamesCount ?? this.likedNamesCount,
      );
}
