import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/pet_remote_data_source.dart';
import '../models/pet_model.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/repositories/pet_repository.dart';

@LazySingleton(as: PetRepository)
class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PetRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> addPet(PetEntity pet, File image) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final petModel = PetModel(
        shelterId: pet.shelterId,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        gender: pet.gender,
        size: pet.size,
        description: pet.description,
        photos: pet.photos,
        status: pet.status,
      );
      
      await remoteDataSource.addPet(petModel, image);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getPets() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      final result = await remoteDataSource.getPets();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getShelterPets() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('Sin internet'));
    try {
      final result = await remoteDataSource.getShelterPets();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('Sin internet'));
    try {
      await remoteDataSource.deletePet(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet(PetEntity pet) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('Sin internet'));
    try {
      // Convertimos Entity a Model para pasarlo al DataSource
      final petModel = PetModel(
        id: pet.id,
        shelterId: pet.shelterId,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        gender: pet.gender,
        size: pet.size,
        description: pet.description,
        photos: pet.photos,
        status: pet.status,
      );
      await remoteDataSource.updatePet(petModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}