import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/adoption_request_entity.dart';
import '../repositories/adoption_repository.dart';

@lazySingleton
class GetAdopterRequests implements UseCase<List<AdoptionRequestEntity>, NoParams> {
  final AdoptionRepository repository;

  GetAdopterRequests(this.repository);

  @override
  Future<Either<Failure, List<AdoptionRequestEntity>>> call(NoParams params) async {
    return await repository.getAdopterRequests();
  }
}