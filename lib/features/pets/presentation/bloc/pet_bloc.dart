import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/usecases/add_pet.dart';
import '../../domain/usecases/get_pets.dart'; // Importar el nuevo UseCase
import '../../domain/usecases/get_shelter_pets.dart';
import '../../domain/usecases/delete_pet.dart';
import '../../domain/usecases/update_pet.dart';
import '../../../../core/usecase/usecase.dart'; // Para NoParams

part 'pet_event.dart';
part 'pet_state.dart';

@injectable
class PetBloc extends Bloc<PetEvent, PetState> {
  final AddPet addPet;
  final GetPets getPets; // <--- Inyectar
  final GetShelterPets getShelterPets;
  final DeletePet deletePet;
  final UpdatePet updatePet;



  PetBloc({
    required this.addPet,
    required this.getPets, // <--- Recibir
    required this.getShelterPets,
    required this.deletePet,
    required this.updatePet,
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

    on<LoadShelterPets>((event, emit) async {
      emit(PetLoading());
      final result = await getShelterPets(NoParams());
      result.fold(
        (l) => emit(PetError(l.toString())),
        (r) => emit(PetsLoaded(r)),
      );
    });

    on<DeletePetRequested>((event, emit) async {
      // Lógica optimista: Borramos y recargamos
      await deletePet(event.petId); // Asumiendo params simples
      add(LoadShelterPets()); 
    });

    on<UpdatePetRequested>((event, emit) async {
      emit(PetLoading());
      // Usamos params para enviar mascota + imagen
      final result = await updatePet(UpdatePetParams(
        pet: event.pet, 
        image: event.image
      ));
      
      result.fold(
        (failure) => emit(PetError(failure.toString())),
        (_) => emit(PetSuccess()),
      );
    });
} }