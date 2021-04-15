import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/name.dart';

abstract class SharingEvent extends Equatable {
  const SharingEvent();

  @override
  List<Object?> get props => [];
}

class SharingEventRefresh extends SharingEvent {}

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
