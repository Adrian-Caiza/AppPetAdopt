import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
    
  });

  // CORRECCIÓN: Se agregó el parámetro 'role' aquí para cumplir el contrato
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
    String? address,
    String? phone,
    double? latitude,
    double? longitude, 
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signInWithGoogle();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? role,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'role': role ?? 'adopter', // Rol por defecto si es nulo
          'address': address,
          'phone_number': phone,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      // Asegúrate de que esta URL esté en la whitelist de Supabase > Auth > URL Configuration
      await supabaseClient.auth.resetPasswordForEmail(
        email, 
        redirectTo: 'https://web-pet-adopt.netlify.app/reset-password'
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
Future<UserModel> signInWithGoogle() async {
  try {
    print('=== INICIANDO GOOGLE SIGN-IN CON SUPABASE ===');
    
    // OPCIÓN 1: Usar OAuthProvider.google (si está disponible)
    await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'loginpro://auth-callback',
    );
    
    // Esperamos un momento para que se complete el flujo OAuth
    await Future.delayed(const Duration(seconds: 3));
    
    // Verificamos si hay un usuario autenticado
    final currentUser = supabaseClient.auth.currentUser;
    
    if (currentUser == null) {
      throw Exception('No se pudo iniciar sesión con Google - Usuario nulo');
    }
    
    print('Usuario autenticado: ${currentUser.email}');
    return UserModel.fromSupabaseUser(currentUser);
    
  } catch (e, stack) {
    print('=== ERROR EN GOOGLE SIGN-IN ===');
    print('Error: $e');
    print('Stack trace: $stack');
    throw Exception('Error en Google Sign-In: $e');
  }
}
}


