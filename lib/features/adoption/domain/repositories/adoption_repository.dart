import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/adoption_request_entity.dart';

abstract class AdoptionRepository {
  Future<Either<Failure, void>> requestAdoption(AdoptionRequestEntity request);
  Future<Either<Failure, List<AdoptionRequestEntity>>> getShelterRequests();
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String newStatus);
  Future<Either<Failure, List<AdoptionRequestEntity>>> getAdopterRequests();
  Stream<AdoptionRequestEntity> get adoptionStream;
}