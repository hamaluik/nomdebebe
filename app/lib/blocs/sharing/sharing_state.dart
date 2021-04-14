import 'package:equatable/equatable.dart';
import 'package:nomdebebe/models/nullable.dart';

class SharingState extends Equatable {
  final String? myID;
  final String? partnerID;
  final List<String> parterNames;
  final String? error;

  const SharingState(this.myID, this.partnerID, this.parterNames, this.error)
      : super();

  SharingState.initial()
      : myID = null,
        partnerID = null,
        parterNames = List.empty(),
        error = null;

  SharingState copyWith(
          {Nullable<String?>? myID,
          Nullable<String?>? partnerID,
          List<String>? parterNames,
          Nullable<String?>? error}) =>
      SharingState(
          myID == null ? this.myID : myID.value,
          partnerID == null ? this.partnerID : partnerID.value,
          parterNames ?? this.parterNames,
          error == null ? this.error : error.value);

  @override
  List<Object?> get props => [myID, partnerID, parterNames, error];
}
