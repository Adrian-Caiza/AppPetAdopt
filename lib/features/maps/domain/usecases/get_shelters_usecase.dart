import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shelter_map_entity.dart';
import '../repositories/maps_repository.dart';

@lazySingleton
class GetSheltersUseCase implements UseCase<List<ShelterMapEntity>, NoParams> {
  final MapsRepository repository;

  GetSheltersUseCase(this.repository);

  @override
  Future<Either<Failure, List<ShelterMapEntity>>> call(NoParams params) async {
    return await repository.getNearbyShelters();
  }
}