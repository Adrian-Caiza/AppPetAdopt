import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shelter_map_entity.dart';

abstract class MapsRepository {
  Future<Either<Failure, List<ShelterMapEntity>>> getNearbyShelters();
}