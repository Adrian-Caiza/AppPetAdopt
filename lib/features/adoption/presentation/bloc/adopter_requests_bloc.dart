import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/usecases/get_adopter_requests.dart';

// --- EVENTOS ---
abstract class AdopterRequestsEvent extends Equatable {
  const AdopterRequestsEvent();

  @override
  List<Object> get props => [];
}

class LoadAdopterRequests extends AdopterRequestsEvent {}

// --- ESTADOS ---
abstract class AdopterRequestsState extends Equatable {
  const AdopterRequestsState();

  @override
  List<Object> get props => [];
}

class AdopterRequestsInitial extends AdopterRequestsState {}

class AdopterRequestsLoading extends AdopterRequestsState {}

class AdopterRequestsLoaded extends AdopterRequestsState {
  final List<AdoptionRequestEntity> requests;

  const AdopterRequestsLoaded(this.requests);

  @override
  List<Object> get props => [requests];
}

class AdopterRequestsError extends AdopterRequestsState {
  final String message;

  const AdopterRequestsError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLOC ---
@injectable
class AdopterRequestsBloc extends Bloc<AdopterRequestsEvent, AdopterRequestsState> {
  final GetAdopterRequests getAdopterRequests;

  AdopterRequestsBloc(this.getAdopterRequests) : super(AdopterRequestsInitial()) {
    
    on<LoadAdopterRequests>((event, emit) async {
      emit(AdopterRequestsLoading());
      
      final result = await getAdopterRequests(NoParams());
      
      result.fold(
        (failure) => emit(AdopterRequestsError(failure.toString())),
        (requests) => emit(AdopterRequestsLoaded(requests)),
      );
    });
  }
}