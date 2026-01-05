import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String? id;
  final String shelterId;
  final String name;
  final String species; // 'dog', 'cat'
  final String? breed;
  final int age;
  final String gender; // 'male', 'female'
  final String size;
  final String description;
  final List<String> photos;
  final String status;

  const PetEntity({
    this.id,
    required this.shelterId,
    required this.name,
    required this.species,
    this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.description,
    required this.photos,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, species, age, status];
}