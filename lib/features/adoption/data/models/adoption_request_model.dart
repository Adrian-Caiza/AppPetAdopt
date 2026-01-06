import '../../domain/entities/adoption_request_entity.dart';

class AdoptionRequestModel extends AdoptionRequestEntity {
  const AdoptionRequestModel({
    super.id,
    required super.petId,
    required super.shelterId,
    super.adopterId,
    required super.message,
    super.status,
    super.createdAt,
    super.petName,
    super.petPhoto,
    super.adopterName,
    super.adopterEmail,
  });

  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    // Supabase devuelve los joins como mapas anidados ('pets': {...}, 'profiles': {...})
    final petData = json['pets'] as Map<String, dynamic>?;
    final adopterData = json['profiles'] as Map<String, dynamic>?; // Asumiendo que profiles es la tabla de usuarios

    return AdoptionRequestModel(
      id: json['id'],
      petId: json['pet_id'],
      shelterId: json['shelter_id'],
      adopterId: json['adopter_id'],
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      
      // Extraemos datos anidados si existen
      petName: petData?['name'],
      petPhoto: (petData?['photos'] as List?)?.isNotEmpty == true ? petData!['photos'][0] : null,
      adopterName: adopterData?['full_name'] ?? 'Usuario', // full_name viene de tu tabla profiles
      adopterEmail: adopterData?['email'], // Ojo: email suele estar en auth.users, pero a veces se copia a profiles
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'shelter_id': shelterId,
      'adopter_id': adopterId,
      'message': message,
      'status': status,
    };
  }
}