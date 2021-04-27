import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/name.dart';

class NamesState extends Equatable {
  final List<Name> undecidedNameBuffer;
  final List<Name> likedNames;
  final int namesCount;
  final int undecidedNamesCount;
  final int likedNamesCount;

  const NamesState(this.undecidedNameBuffer, this.likedNames, this.namesCount,
      this.undecidedNamesCount, this.likedNamesCount);

  NamesState.initial()
      : undecidedNameBuffer = [],
        likedNames = [],
        namesCount = 0,
        undecidedNamesCount = 0,
        likedNamesCount = 0;

  @override
  List<Object?> get props => [
        undecidedNameBuffer,
        likedNames,
        namesCount,
        undecidedNamesCount,
        likedNamesCount
      ];

  NamesState copyWith({
    List<Name>? undecidedNameBuffer,
    List<Name>? likedNames,
    int? namesCount,
    int? undecidedNamesCount,
    int? likedNamesCount,
  }) =>
      NamesState(
        undecidedNameBuffer ?? this.undecidedNameBuffer,
        likedNames ?? this.likedNames,
        namesCount ?? this.namesCount,
        undecidedNamesCount ?? this.undecidedNamesCount,
        likedNamesCount ?? this.likedNamesCount,
      );
}
