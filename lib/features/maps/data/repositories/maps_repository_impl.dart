import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_remote_data_source.dart';
import '../../domain/entities/shelter_map_entity.dart';

@LazySingleton(as: MapsRepository)
class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDataSource dataSource;

  MapsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ShelterMapEntity>>> getNearbyShelters() async {
    try {
      final result = await dataSource.getShelters();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}