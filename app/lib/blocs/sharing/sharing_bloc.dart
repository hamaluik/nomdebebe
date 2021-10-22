import 'package:bloc/bloc.dart';
import 'package:nomdebebe/blocs/sharing/sharing_events.dart';
import 'package:nomdebebe/blocs/sharing/sharing_state.dart';
import 'package:nomdebebe/models/name.dart';
import 'package:nomdebebe/repositories/shared_repository.dart';
import 'package:nomdebebe/models/nullable.dart';

class SharingBloc extends Bloc<SharingEvent, SharingState> {
  final SharedRepository sharedRepository;

  SharingBloc(this.sharedRepository) : super(SharingState.initial());

  // provide a public API for this so that the app can await the future and
  // use it to update the UI appropriately
  Future<void> refreshSharing() async {
    String? id = await sharedRepository.myID;
    String? partnerID = sharedRepository.partnerID;
    List<Name>? partnerNames = partnerID == null
        ? List.empty()
        : await sharedRepository.getParterNames(partnerID);
    String? error = id == null || partnerNames == null
        ? "Failed to contact sharing server"
        : null;

    //print("my id: $id");
    //print("partner id: $partnerID");
    //print("partner names: $partnerNames");
    //print("error: $error");

    this.add(SharingEventSet(id, partnerID, partnerNames, error));
  }

  @override
  Stream<SharingState> mapEventToState(SharingEvent event) async* {
    if (event is SharingEventSet) {
      yield SharingState(event.myID, event.partnerID,
          event.partnerNames ?? List.empty(), event.error);
    } else if (event is SharingEventSetPartnerID) {
      sharedRepository.partnerID = event.partnerID;
      List<Name>? partnerNames = sharedRepository.partnerID == null
          ? List.empty()
          : await sharedRepository.getParterNames(sharedRepository.partnerID!);
      String? error =
          partnerNames == null ? "Failed to contact sharing server" : null;
      await refreshSharing();
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
      await refreshSharing();
      yield state.copyWith(error: Nullable(error));
    } else if (event is SharingEventGetNewCode) {
      String? id = await sharedRepository.resetMyID();
      await sharedRepository.setLikedNames(event.names);
      yield state.copyWith(myID: Nullable(id));
    }
  }
}
