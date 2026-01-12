import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    // 1. Obtenemos el resultado del repositorio
    final result = await repository.getCurrentUser();

    // 2. Procesamos el resultado usando .fold
    return result.fold(
      (failure) {
        // Si ya venía con error, lo devolvemos tal cual
        return Left(failure);
      },
      (user) {
        // Si la operación fue exitosa, verificamos si el usuario es nulo
        if (user != null) {
          return Right(user); // ¡Todo bien! Hay usuario
        } else {
          // Si es nulo, significa que no hay sesión activa.
          // Devolvemos un Failure para que el Bloc emita "Unauthenticated"
          return const Left(ServerFailure('No hay sesión activa'));
        }
      },
    );
  }
}