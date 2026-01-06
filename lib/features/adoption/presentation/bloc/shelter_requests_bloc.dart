import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/usecases/get_shelter_requests.dart';
import '../../domain/usecases/update_adoption_status.dart';

// Eventos
abstract class ShelterRequestsEvent extends Equatable {
  const ShelterRequestsEvent();
  @override
  List<Object> get props => [];
}

class LoadShelterRequests extends ShelterRequestsEvent {}

class UpdateRequestStatusEvent extends ShelterRequestsEvent {
  final String requestId;
  final String newStatus; // 'approved' o 'rejected'

  const UpdateRequestStatusEvent(this.requestId, this.newStatus);
}

// Estados
abstract class ShelterRequestsState extends Equatable {
  const ShelterRequestsState();
  @override
  List<Object> get props => [];
}

class ShelterRequestsInitial extends ShelterRequestsState {}
class ShelterRequestsLoading extends ShelterRequestsState {}

class ShelterRequestsLoaded extends ShelterRequestsState {
  final List<AdoptionRequestEntity> requests;
  const ShelterRequestsLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}

class ShelterRequestsError extends ShelterRequestsState {
  final String message;
  const ShelterRequestsError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
@injectable
class ShelterRequestsBloc extends Bloc<ShelterRequestsEvent, ShelterRequestsState> {
  final GetShelterRequests getShelterRequests;
  final UpdateAdoptionStatus updateAdoptionStatus;

  ShelterRequestsBloc(this.getShelterRequests, this.updateAdoptionStatus)
      : super(ShelterRequestsInitial()) {
    
    on<LoadShelterRequests>((event, emit) async {
      emit(ShelterRequestsLoading());
      final result = await getShelterRequests(NoParams());
      result.fold(
        (failure) => emit(ShelterRequestsError(failure.toString())),
        (requests) => emit(ShelterRequestsLoaded(requests)),
      );
    });

    on<UpdateRequestStatusEvent>((event, emit) async {
      // Nota: Idealmente actualizamos optimísticamente o recargamos.
      // Aquí haremos recarga simple.
      final result = await updateAdoptionStatus(
        UpdateAdoptionStatusParams(requestId: event.requestId, status: event.newStatus),
      );
      
      result.fold(
        (failure) => emit(ShelterRequestsError(failure.toString())),
        (_) => add(LoadShelterRequests()), // Recargar lista tras éxito
      );
    });
  }
}