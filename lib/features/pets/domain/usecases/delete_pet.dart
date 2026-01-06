import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/pet_repository.dart';

@lazySingleton
class DeletePet implements UseCase<void, String> {
  final PetRepository repository;

  DeletePet(this.repository);

  @override
  Future<Either<Failure, void>> call(String petId) async {
    return await repository.deletePet(petId);
  }
}