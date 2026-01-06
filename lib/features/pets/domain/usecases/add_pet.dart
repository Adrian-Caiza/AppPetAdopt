import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

@lazySingleton
class AddPet implements UseCase<void, AddPetParams> {
  final PetRepository repository;

  AddPet(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPetParams params) async {
    return await repository.addPet(params.pet, params.image);
  }
}

class AddPetParams {
  final PetEntity pet;
  final File image;

  AddPetParams({required this.pet, required this.image});
}