import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final SupabaseClient client;
  PetRemoteDataSourceImpl(this.client);

  Future<void> addPet(PetModel pet, File imageFile) async {
    // 1. Subir imagen al Storage [cite: 70]
    final fileName = '${DateTime.now().toIso8601String()}_${pet.name}';
    await client.storage.from('pets').upload(fileName, imageFile);
    final imageUrl = client.storage.from('pets').getPublicUrl(fileName);

    // 2. Guardar en Base de Datos [cite: 69]
    await client.from('pets').insert({
      ...pet.toJson(),
      'shelter_id': client.auth.currentUser!.id,
      'photos': [imageUrl], // Guardamos como array
    });
  }

  Future<List<PetModel>> getPets() async {
    final response = await client.from('pets').select().eq('status', 'available');
    return response.map((json) => PetModel.fromJson(json)).toList();
  }
}