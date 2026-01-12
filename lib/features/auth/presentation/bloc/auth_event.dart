import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role; // <--- NUEVO CAMPO
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [email, password, displayName, role, address, phone, latitude, longitude];
}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  const ResetPasswordRequested({required this.email});
  
  @override
  List<Object> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {}
class CheckAuthStatusRequested extends AuthEvent {} 
