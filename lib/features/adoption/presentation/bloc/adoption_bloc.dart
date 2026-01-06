import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/usecases/submit_adoption_request.dart';

// Eventos
abstract class AdoptionEvent extends Equatable {
  const AdoptionEvent();
  @override
  List<Object> get props => [];
}

class SubmitRequest extends AdoptionEvent {
  final String petId;
  final String shelterId;
  final String message;

  const SubmitRequest({
    required this.petId,
    required this.shelterId,
    required this.message,
  });
}

// Estados
abstract class AdoptionState extends Equatable {
  const AdoptionState();
  @override
  List<Object> get props => [];
}

class AdoptionInitial extends AdoptionState {}
class AdoptionLoading extends AdoptionState {}
class AdoptionSuccess extends AdoptionState {}
class AdoptionError extends AdoptionState {
  final String message;
  const AdoptionError(this.message);
}

@injectable
class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final SubmitAdoptionRequest submitRequest;

  AdoptionBloc(this.submitRequest) : super(AdoptionInitial()) {
    on<SubmitRequest>((event, emit) async {
      emit(AdoptionLoading());
      
      final request = AdoptionRequestEntity(
        petId: event.petId,
        shelterId: event.shelterId,
        message: event.message,
      );

      final result = await submitRequest(request);

      result.fold(
        (failure) => emit(AdoptionError(failure.toString())),
        (_) => emit(AdoptionSuccess()),
      );
    });
  }
}