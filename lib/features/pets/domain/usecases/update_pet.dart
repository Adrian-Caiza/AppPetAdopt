import 'dart:io'; // <--- Agrega este import
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

@lazySingleton
class UpdatePet implements UseCase<void, UpdatePetParams> {
  final PetRepository repository;

  UpdatePet(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePetParams params) async {
    return await repository.updatePet(params.pet, params.image);
  }
}

// Clase auxiliar para pasar los parámetros
class UpdatePetParams {
  final PetEntity pet;
  final File? image;

  UpdatePetParams({required this.pet, this.image});
}