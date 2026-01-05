import '../../domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    super.id,
    required super.shelterId,
    required super.name,
    required super.species,
    super.breed,
    required super.age,
    required super.gender,
    required super.size,
    required super.description,
    required super.photos,
    required super.status,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      shelterId: json['shelter_id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      age: json['age'],
      gender: json['gender'],
      size: json['size'],
      description: json['description'],
      photos: List<String>.from(json['photos'] ?? []),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shelter_id': shelterId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'description': description,
      'photos': photos, // Supabase maneja arrays de texto
      'status': status,
    };
  }
}