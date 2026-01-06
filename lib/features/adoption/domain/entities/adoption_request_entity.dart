import 'package:equatable/equatable.dart';

class AdoptionRequestEntity extends Equatable {
  final String? id;
  final String petId;
  final String shelterId;
  final String? adopterId;
  final String message;
  final String status;
  final DateTime? createdAt;
  
  // Campos nuevos para mostrar información 
  final String? petName;
  final String? petPhoto;
  final String? adopterName;
  final String? adopterEmail;

  const AdoptionRequestEntity({
    this.id,
    required this.petId,
    required this.shelterId,
    this.adopterId,
    required this.message,
    this.status = 'pending',
    this.createdAt,
    this.petName,
    this.petPhoto,
    this.adopterName,
    this.adopterEmail,
  });

  @override
  List<Object?> get props => [id, petId, shelterId, status, petName, adopterName];
}