import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';
import 'package:namekit/models/nullable.dart';

class NamesState extends Equatable {
  final Name? nextUndecidedName;
  final int namesCount;
  final int undecidedNamesCount;
  final int likedNamesCount;

  const NamesState(this.nextUndecidedName, this.namesCount,
      this.undecidedNamesCount, this.likedNamesCount);

  NamesState.initial()
      : nextUndecidedName = null,
        namesCount = 0,
        undecidedNamesCount = 0,
        likedNamesCount = 0;

  @override
  List<Object?> get props =>
      [nextUndecidedName, namesCount, undecidedNamesCount, likedNamesCount];

  NamesState copyWith({
    Nullable<Name?>? nextUndecidedName,
    int? namesCount,
    int? undecidedNamesCount,
    int? likedNamesCount,
  }) =>
      NamesState(
        nextUndecidedName == null
            ? this.nextUndecidedName
            : nextUndecidedName.value,
        namesCount ?? this.namesCount,
        undecidedNamesCount ?? this.undecidedNamesCount,
        likedNamesCount ?? this.likedNamesCount,
      );
}
