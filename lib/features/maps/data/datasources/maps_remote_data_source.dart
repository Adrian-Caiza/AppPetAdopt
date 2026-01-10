import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shelter_map_model.dart';

abstract class MapsRemoteDataSource {
  Future<List<ShelterMapModel>> getShelters();
}

@LazySingleton(as: MapsRemoteDataSource)
class MapsRemoteDataSourceImpl implements MapsRemoteDataSource {
  final SupabaseClient client;

  MapsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ShelterMapModel>> getShelters() async {
    try {
      // Consultamos la tabla 'profiles' filtrando por rol 'shelter'
      // Asegúrate de tener las columnas latitude y longitude en Supabase
      final response = await client
          .from('profiles') 
          .select()
          .eq('role', 'shelter'); // O como identifiques a los refugios

      // Filtramos los que no tengan ubicación válida
      final List<dynamic> data = response;
      return data
          .map((json) => ShelterMapModel.fromJson(json))
          .where((s) => s.latitude != 0.0 && s.longitude != 0.0) // Solo mostrar los que tienen ubicación
          .toList();
    } catch (e) {
      throw Exception('Error al obtener refugios: $e');
    }
  }
}