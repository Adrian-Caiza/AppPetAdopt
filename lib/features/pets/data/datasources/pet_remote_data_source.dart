import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';

abstract class PetRemoteDataSource {
  Future<void> addPet(PetModel pet, File imageFile);
  Future<List<PetModel>> getPets();
  Future<List<PetModel>> getShelterPets(); 
  Future<void> deletePet(String id);
  Future<void> updatePet(PetModel pet, File? imageFile);
}

@LazySingleton(as: PetRemoteDataSource)
class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final SupabaseClient client;

  PetRemoteDataSourceImpl(this.client);

  @override
  Future<void> addPet(PetModel pet, File imageFile) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // 1. Subir imagen
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}_${pet.name}.$fileExt';
      
      await client.storage.from('pets').upload(fileName, imageFile);
      
      final imageUrl = client.storage.from('pets').getPublicUrl(fileName);

      // 2. Guardar datos
      // Nota: Creamos un modelo nuevo con la URL actualizada y el ID del refugio
      final petToSave = PetModel(
        shelterId: user.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        age: pet.age,
        gender: pet.gender,
        size: pet.size,
        description: pet.description,
        photos: [imageUrl],
        status: 'available',
      );

      await client.from('pets').insert(petToSave.toJson());
    } catch (e) {
      throw Exception('Error al guardar mascota: $e');
    }
  }

  @override
  Future<List<PetModel>> getPets() async {
    try {
      final response = await client
          .from('pets')
          .select()
          .eq('status', 'available')
          .order('created_at', ascending: false);
          
      return (response as List).map((json) => PetModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar mascotas: $e');
    }
  }

  @override
  Future<List<PetModel>> getShelterPets() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No autenticado');
      
      final response = await client
          .from('pets')
          .select()
          .eq('shelter_id', user.id) // Filtra por MI ID
          .order('created_at', ascending: false);
      return (response as List).map((json) => PetModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar mis mascotas: $e');
    }
  }

  @override
  Future<void> deletePet(String id) async {
    await client.from('pets').delete().eq('id', id);
  }

  @override
  Future<void> updatePet(PetModel pet, File? imageFile) async {
    try {
      List<String> photoUrls = pet.photos;

      // 1. Si hay nueva imagen, subirla y actualizar la lista de URLs
      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pet.name}.$fileExt';
        
        // Subir al bucket 'pets'
        await client.storage.from('pets').upload(fileName, imageFile);
        
        // Obtener URL pública
        final newImageUrl = client.storage.from('pets').getPublicUrl(fileName);
        
        // Reemplazamos la foto anterior (o agregamos si prefieres)
        // Aquí asumimos que solo tiene 1 foto principal
        photoUrls = [newImageUrl];
      }

      // 2. Actualizar datos en la tabla (incluyendo la foto nueva si hubo cambio)
      await client.from('pets').update({
        'name': pet.name,
        'breed': pet.breed,
        'age': pet.age,
        'species': pet.species,
        'gender': pet.gender,
        'size': pet.size,
        'description': pet.description,
        'status': pet.status,
        'photos': photoUrls, 
      }).eq('id', pet.id!);

    } catch (e) {
      throw Exception('Error al actualizar mascota: $e');
    }
  }
}
