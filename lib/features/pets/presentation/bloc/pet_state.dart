part of 'pet_bloc.dart';

abstract class PetState extends Equatable {
  const PetState();
  @override
  List<Object> get props => [];
}

class PetInitial extends PetState {}
class PetLoading extends PetState {}
class PetSuccess extends PetState {} // Para cuando se sube exitosamente

// NUEVO ESTADO
class PetsLoaded extends PetState {
  final List<PetEntity> pets;
  const PetsLoaded(this.pets);
  
  @override
  List<Object> get props => [pets];
}

class PetError extends PetState {
  final String message;
  const PetError(this.message);
  
  @override
  List<Object> get props => [message];
}