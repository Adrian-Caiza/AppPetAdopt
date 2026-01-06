import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/adoption_request_entity.dart';
import '../repositories/adoption_repository.dart';

@lazySingleton
class SubmitAdoptionRequest implements UseCase<void, AdoptionRequestEntity> {
  final AdoptionRepository repository;

  SubmitAdoptionRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(AdoptionRequestEntity params) async {
    return await repository.requestAdoption(params);
  }
}