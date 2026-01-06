part of 'pet_bloc.dart';

abstract class PetEvent extends Equatable {
  const PetEvent();
  @override
  List<Object> get props => [];
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