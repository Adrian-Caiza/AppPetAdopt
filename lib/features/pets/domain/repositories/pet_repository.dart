import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';

abstract class PetRepository {
  Future<Either<Failure, void>> addPet(PetEntity pet, File image);
  Future<Either<Failure, List<PetEntity>>> getPets();
  Future<Either<Failure, List<PetEntity>>> getShelterPets();
  Future<Either<Failure, void>> deletePet(String id);
  Future<Either<Failure, void>> updatePet(PetEntity pet, File? image);
  
}