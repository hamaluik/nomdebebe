import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/name.dart';

enum DecisionType {
  Liked,
  Disliked,
}

class DecisionNode {
  final Name name;
  final DecisionType type;

  const DecisionNode(this.name, this.type);
}

class NamesState extends Equatable {
  final List<Name> undecidedNameBuffer;
  final List<Name> likedNames;
  final int namesCount;
  final int undecidedNamesCount;
  final int likedNamesCount;
  final List<DecisionNode> decisionHistory;

  const NamesState(this.undecidedNameBuffer, this.likedNames, this.namesCount,
      this.undecidedNamesCount, this.likedNamesCount, this.decisionHistory);

  NamesState.initial()
      : undecidedNameBuffer = [],
        likedNames = [],
        namesCount = 0,
        undecidedNamesCount = 0,
        likedNamesCount = 0,
        decisionHistory = [];

  @override
  List<Object?> get props => [
        undecidedNameBuffer,
        likedNames,
        namesCount,
        undecidedNamesCount,
        likedNamesCount,
        decisionHistory,
      ];

  NamesState copyWith({
    List<Name>? undecidedNameBuffer,
    List<Name>? likedNames,
    int? namesCount,
    int? undecidedNamesCount,
    int? likedNamesCount,
    List<DecisionNode>? decisionHistory,
  }) =>
      NamesState(
        undecidedNameBuffer ?? this.undecidedNameBuffer,
        likedNames ?? this.likedNames,
        namesCount ?? this.namesCount,
        undecidedNamesCount ?? this.undecidedNamesCount,
        likedNamesCount ?? this.likedNamesCount,
        decisionHistory ?? this.decisionHistory,
      );
}
