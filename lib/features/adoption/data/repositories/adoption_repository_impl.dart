import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/adoption_remote_data_source.dart';
import '../models/adoption_request_model.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../../domain/repositories/adoption_repository.dart';

@LazySingleton(as: AdoptionRepository)
class AdoptionRepositoryImpl implements AdoptionRepository {
  final AdoptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdoptionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> requestAdoption(AdoptionRequestEntity request) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final model = AdoptionRequestModel(
        petId: request.petId,
        shelterId: request.shelterId,
        message: request.message,
      );
      await remoteDataSource.createRequest(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdoptionRequestEntity>>> getShelterRequests() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final result = await remoteDataSource.getShelterRequests();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String newStatus) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      await remoteDataSource.updateStatus(requestId, newStatus);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdoptionRequestEntity>>> getAdopterRequests() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('Sin internet'));
    try {
      final result = await remoteDataSource.getAdopterRequests();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
