import '../../domain/entities/shelter_map_entity.dart';

class ShelterMapModel extends ShelterMapEntity {
  const ShelterMapModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    super.phone,
    super.address,
  });

  factory ShelterMapModel.fromJson(Map<String, dynamic> json) {
    return ShelterMapModel(
      id: json['id'],
      name: json['full_name'] ?? 'Refugio Sin Nombre', // Ajusta según tu columna en BD
      // Usamos valores por defecto si son nulos para evitar errores, o 0.0
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'], // Ajusta según tu columna
      address: json['address'],    // Ajusta según tu columna
    );
  }
}