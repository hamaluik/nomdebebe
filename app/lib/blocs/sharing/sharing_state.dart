import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/models/nullable.dart';

class SharingState extends Equatable {
  final String? myID;
  final String? partnerID;
  final List<Name> partnerNames;
  final String? error;
  final bool loading;

  const SharingState(
      this.myID, this.partnerID, this.partnerNames, this.error, this.loading)
      : super();

  SharingState.initial()
      : myID = null,
        partnerID = null,
        partnerNames = List.empty(),
        error = null,
        loading = false;

  SharingState copyWith(
          {Nullable<String?>? myID,
          Nullable<String?>? partnerID,
          List<Name>? partnerNames,
          Nullable<String?>? error,
          bool? loading}) =>
      SharingState(
          myID == null ? this.myID : myID.value,
          partnerID == null ? this.partnerID : partnerID.value,
          partnerNames ?? this.partnerNames,
          error == null ? this.error : error.value,
          loading ?? this.loading);

  @override
  List<Object?> get props => [myID, partnerID, partnerNames, error, loading];
}
