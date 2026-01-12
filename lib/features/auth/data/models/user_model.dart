import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.createdAt,
    super.fullName,
    super.phone,
    super.address,
    super.avatarUrl,
    super.userMetadata,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      fullName: user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
      phone: user.phone ?? user.userMetadata?['phone'] as String?, // El teléfono puede venir directo o en metadata
      address: user.userMetadata?['address'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      userMetadata: user.userMetadata,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      fullName: fullName,
      phone: phone,
      address: address,
      avatarUrl: avatarUrl,
      userMetadata: userMetadata,
    );
  }
}
