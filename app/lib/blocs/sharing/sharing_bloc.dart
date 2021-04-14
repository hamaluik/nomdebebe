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
      String? parterID = sharedRepository.parterID;
      List<String>? partnerNames = parterID == null
          ? List.empty()
          : await sharedRepository.getParterNames(parterID);
      String? error = id == null || partnerNames == null
          ? "Failed to contact sharing server"
          : null;

      yield SharingState(id, parterID, partnerNames ?? List.empty(), error);
    } else if (event is SharingEventSetPartnerID) {
      sharedRepository.parterID = event.partnerID;
      yield state.copyWith(partnerID: Nullable(event.partnerID));
    } else if (event is SharingEventUpdateLikedNames) {
      String? error;
      try {
        sharedRepository.setLikedNames(event.names);
      } catch (e) {
        error = "Failed to share liked names";
      }
      yield state.copyWith(error: Nullable(error));
    }
  }
}
