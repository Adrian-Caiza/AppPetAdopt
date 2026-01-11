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
      address: params.address,
      phone: params.phone,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String? displayName;
  final String role; // <--- Asegúrate de tener este campo
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;

  SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
    required this.role, // <--- Y requerirlo en el constructor
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
  });
}