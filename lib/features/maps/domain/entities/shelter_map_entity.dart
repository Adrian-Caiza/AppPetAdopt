import 'package:equatable/equatable.dart';

class ShelterMapEntity extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? address;

  const ShelterMapEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}