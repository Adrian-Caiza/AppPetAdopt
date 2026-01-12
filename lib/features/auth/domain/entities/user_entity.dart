import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final String fullName;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final Map<String, dynamic>? userMetadata;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.fullName = '',
    this.phone,
    this.address,
    this.avatarUrl,
    this.userMetadata,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt, fullName, phone, address, avatarUrl, userMetadata];
}
