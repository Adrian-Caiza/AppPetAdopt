import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

@lazySingleton
class UpdatePet implements UseCase<void, PetEntity> {
  final PetRepository repository;

  UpdatePet(this.repository);

  @override
  Future<Either<Failure, void>> call(PetEntity pet) async {
    return await repository.updatePet(pet);
  }
}