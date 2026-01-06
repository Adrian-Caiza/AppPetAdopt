part of 'pet_bloc.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();
  @override
  List<Object?> get props => [];
}

class AddPetRequested extends PetEvent {
  final PetEntity pet;
  final File image;
  const AddPetRequested({required this.pet, required this.image});
}

// NUEVO EVENTO
class GetPetsRequested extends PetEvent {
  const GetPetsRequested();
}

class LoadShelterPets extends PetEvent {}
class DeletePetRequested extends PetEvent {
  final String petId;
  const DeletePetRequested(this.petId);
}

class UpdatePetRequested extends PetEvent {
  final PetEntity pet;
  final File? image;
  
  const UpdatePetRequested({required this.pet, this.image});

  @override
  List<Object?> get props => [pet, image];
}