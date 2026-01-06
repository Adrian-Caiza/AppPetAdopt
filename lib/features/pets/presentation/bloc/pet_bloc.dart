import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/usecases/add_pet.dart';
import '../../domain/usecases/get_pets.dart'; // Importar el nuevo UseCase
import '../../../../core/usecase/usecase.dart'; // Para NoParams

part 'pet_event.dart';
part 'pet_state.dart';

@injectable
class PetBloc extends Bloc<PetEvent, PetState> {
  final AddPet addPet;
  final GetPets getPets; // <--- Inyectar

  PetBloc({
    required this.addPet,
    required this.getPets, // <--- Recibir
  }) : super(PetInitial()) {
    
    // Handler para Agregar (Ya lo tenías)
    on<AddPetRequested>((event, emit) async {
      emit(PetLoading());
      final result = await addPet(AddPetParams(pet: event.pet, image: event.image));
      result.fold(
        (failure) => emit(PetError(failure.toString())),
        (_) => emit(PetSuccess()),
      );
    });

    // NUEVO: Handler para Obtener lista
    on<GetPetsRequested>((event, emit) async {
      emit(PetLoading());
      final result = await getPets(NoParams());
      result.fold(
        (failure) => emit(PetError(failure.toString())),
        (pets) => emit(PetsLoaded(pets)),
      );
    });
  }
}