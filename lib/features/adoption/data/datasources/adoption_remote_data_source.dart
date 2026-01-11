import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_request_model.dart';

abstract class AdoptionRemoteDataSource {
  Future<void> createRequest(AdoptionRequestModel request);
  Future<List<AdoptionRequestModel>> getShelterRequests(); // Nuevo
  Future<void> updateStatus(String id, String status); // Nuevo
  Future<List<AdoptionRequestModel>> getAdopterRequests();
  Stream<Map<String, dynamic>> listenToAdoptionChanges();
}

@LazySingleton(as: AdoptionRemoteDataSource)
class AdoptionRemoteDataSourceImpl implements AdoptionRemoteDataSource {
  final SupabaseClient client;

  AdoptionRemoteDataSourceImpl(this.client);

  @override
  Future<void> createRequest(AdoptionRequestModel request) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Creamos el mapa de datos y asignamos el ID del usuario actual como adoptante
      final data = request.toJson();
      data['adopter_id'] = user.id;

      await client.from('adoption_requests').insert(data);
    } catch (e) {
      throw Exception('Error al enviar solicitud: $e');
    }
  }
  // IMPLEMENTACIÓN NUEVA
  @override
  Future<List<AdoptionRequestModel>> getShelterRequests() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // SELECT con Relaciones (Joins)
      // Traemos la solicitud, y expandimos 'pets' y 'profiles' (usando la FK adopter_id)
      final response = await client
          .from('adoption_requests')
          .select('*, pets(*), profiles!adoption_requests_adopter_id_fkey(*)') 
          // NOTA: 'profiles!adoption_requests_adopter_id_fkey' especifica qué relación usar si es ambigua. 
          // Si Supabase detecta la FK automáticamente, basta con 'profiles(*)'.
          // Si te da error, intenta solo 'profiles(*)' o revisa el nombre de tu FK en Supabase.
          .eq('shelter_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => AdoptionRequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    try {
      await client.from('adoption_requests').update({'status': status}).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getAdopterRequests() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No autenticado');

      final response = await client
          .from('adoption_requests')
          .select('*, pets(*)') // Traemos datos de la mascota también
          .eq('adopter_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => AdoptionRequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar mis solicitudes: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>> listenToAdoptionChanges() {
    // 1. Creamos un controlador de Stream. 
    // Esto actúa como un "tubo": metemos datos por un lado (desde Supabase) 
    // y salen por el otro (hacia tu Bloc).
    late StreamController<Map<String, dynamic>> controller;
    RealtimeChannel? channel;

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        // 2. Cuando alguien empieza a escuchar el stream, nos conectamos a Supabase
        channel = client.channel('public:adoption_requests');
        
        channel?.onPostgresChanges(
          event: PostgresChangeEvent.all, // Escuchamos INSERT y UPDATE
          schema: 'public',
          table: 'adoption_requests',
          callback: (payload) {
            // 3. AQUÍ ES DONDE OCURRE LA MAGIA DEL CALLBACK
            // Cuando llega un evento, lo metemos al StreamController
            if (payload.newRecord != null) {
              controller.add(payload.newRecord!);
            }
          },
        ).subscribe(); // <--- No olvides suscribirte
      },
      onCancel: () {
        // 4. Limpieza: Si el Bloc deja de escuchar, cerramos el canal para ahorrar recursos
        if (channel != null) {
          client.removeChannel(channel!);
        }
        controller.close();
      },
    );

    return controller.stream;
  }
}


