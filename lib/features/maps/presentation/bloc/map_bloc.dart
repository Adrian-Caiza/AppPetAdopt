import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/shelter_map_entity.dart';
import '../../domain/usecases/get_shelters_usecase.dart';

// Eventos
abstract class MapEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadMapShelters extends MapEvent {}

// Estados
abstract class MapState extends Equatable {
  @override
  List<Object> get props => [];
}
class MapInitial extends MapState {}
class MapLoading extends MapState {}
class MapLoaded extends MapState {
  final List<ShelterMapEntity> shelters;
  MapLoaded(this.shelters);
  @override
  List<Object> get props => [shelters];
}
class MapError extends MapState {
  final String message;
  MapError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetSheltersUseCase getShelters;

  MapBloc(this.getShelters) : super(MapInitial()) {
    on<LoadMapShelters>((event, emit) async {
      emit(MapLoading());
      final result = await getShelters(NoParams());
      result.fold(
        (failure) => emit(MapError(failure.message)),
        (shelters) => emit(MapLoaded(shelters)),
      );
    });
  }
}