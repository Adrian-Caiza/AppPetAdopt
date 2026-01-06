import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

@lazySingleton
class GetPets implements UseCase<List<PetEntity>, NoParams> {
  final PetRepository repository;

  GetPets(this.repository);

  @override
  Future<Either<Failure, List<PetEntity>>> call(NoParams params) async {
    return await repository.getPets();
  }
}