import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';

abstract class PetRepository {
  Future<Either<Failure, void>> addPet(PetEntity pet, File image);
  Future<Either<Failure, List<PetEntity>>> getPets();
}