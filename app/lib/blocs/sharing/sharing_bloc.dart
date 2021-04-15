import 'package:bloc/bloc.dart';
import 'package:nomdebebe/blocs/sharing/sharing_events.dart';
import 'package:nomdebebe/blocs/sharing/sharing_state.dart';
import 'package:nomdebebe/repositories/shared_repository.dart';
import 'package:nomdebebe/models/nullable.dart';

class SharingBloc extends Bloc<SharingEvent, SharingState> {
  final SharedRepository sharedRepository;

  SharingBloc(this.sharedRepository) : super(SharingState.initial());

  @override
  Stream<SharingState> mapEventToState(SharingEvent event) async* {
    if (event is SharingEventRefresh) {
      String? id = await sharedRepository.myID;
      String? partnerID = sharedRepository.partnerID;
      List<String>? partnerNames = partnerID == null
          ? List.empty()
          : await sharedRepository.getParterNames(partnerID);
      String? error = id == null || partnerNames == null
          ? "Failed to contact sharing server"
          : null;

      //print("my id: $id");
      //print("partner id: $partnerID");
      //print("partner names: $partnerNames");

      yield SharingState(id, partnerID, partnerNames ?? List.empty(), error);
    } else if (event is SharingEventSetPartnerID) {
      sharedRepository.partnerID = event.partnerID;
      List<String>? partnerNames = sharedRepository.partnerID == null
          ? List.empty()
          : await sharedRepository.getParterNames(sharedRepository.partnerID!);
      String? error =
          partnerNames == null ? "Failed to contact sharing server" : null;
      yield state.copyWith(
          partnerID: Nullable(event.partnerID),
          partnerNames: partnerNames,
          error: Nullable(error));
    } else if (event is SharingEventUpdateLikedNames) {
      String? error;
      try {
        sharedRepository.setLikedNames(event.names);
      } catch (e) {
        //print("Failed to upload liked names ${event.names}: $e");
        error = "Failed to share liked names";
      }
      add(SharingEventRefresh());
      yield state.copyWith(error: Nullable(error));
    }
  }
}
