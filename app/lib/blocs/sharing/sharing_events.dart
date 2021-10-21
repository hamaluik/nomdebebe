import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/name.dart';

abstract class SharingEvent extends Equatable {
  const SharingEvent();

  @override
  List<Object?> get props => [];
}

class SharingEventSet extends SharingEvent {
  final String? myID;
  final String? partnerID;
  final List<Name>? partnerNames;
  final String? error;

  const SharingEventSet(
      this.myID, this.partnerID, this.partnerNames, this.error);

  @override
  List<Object?> get props => [myID, partnerID, partnerNames, error];
}

class SharingEventSetPartnerID extends SharingEvent {
  final String? partnerID;
  const SharingEventSetPartnerID(this.partnerID);
  @override
  List<Object?> get props => [partnerID];
}

class SharingEventUpdateLikedNames extends SharingEvent {
  final List<Name> names;
  const SharingEventUpdateLikedNames(this.names);
  @override
  List<Object?> get props => [names];
}

class SharingEventGetNewCode extends SharingEvent {
  final List<Name> names;
  const SharingEventGetNewCode(this.names);
  @override
  List<Object?> get props => [names];
}
