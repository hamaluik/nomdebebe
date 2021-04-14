import 'package:equatable/equatable.dart';
import 'package:namekit/models/name.dart';

abstract class NamesEvent extends Equatable {
  const NamesEvent();

  @override
  List<Object> get props => [];
}

class NamesLoad extends NamesEvent {}

class NamesLike extends NamesEvent {
  final Name name;

  const NamesLike(this.name);

  @override
  List<Object> get props => [name];
}

class NamesDislike extends NamesEvent {
  final Name name;

  const NamesDislike(this.name);

  @override
  List<Object> get props => [name];
}

class NamesUndecide extends NamesEvent {
  final Name name;

  const NamesUndecide(this.name);

  @override
  List<Object> get props => [name];
}

class NamesLikedRank extends NamesEvent {
  final int oldRank;
  final int newRank;
  const NamesLikedRank(this.oldRank, this.newRank);
  @override
  List<Object> get props => [this.oldRank, this.newRank];
}

class NamesFactoryReset extends NamesEvent {}
