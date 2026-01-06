import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/adoption_repository.dart';

@lazySingleton
class UpdateAdoptionStatus implements UseCase<void, UpdateAdoptionStatusParams> {
  final AdoptionRepository repository;

  UpdateAdoptionStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateAdoptionStatusParams params) async {
    return await repository.updateRequestStatus(params.requestId, params.status);
  }
}

class UpdateAdoptionStatusParams {
  final String requestId;
  final String status;
  UpdateAdoptionStatusParams({required this.requestId, required this.status});
}