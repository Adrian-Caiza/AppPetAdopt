import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignUp implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    // Ahora el método signUpWithEmailAndPassword sí tiene el parámetro 'role'
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      role: params.role, 
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String? displayName;
  final String role; // <--- Asegúrate de tener este campo

  SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
    required this.role, // <--- Y requerirlo en el constructor
  });
}