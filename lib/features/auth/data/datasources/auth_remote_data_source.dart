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

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
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
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await supabaseClient.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      throw Exception('Error actualizando perfil: $e');
    }
  }

  @override
Future<UserModel> signInWithGoogle() async {
  try {
    print('=== PRUEBA DE FLUJOS GOOGLE ===');
    print('1. Probando Implicit Flow primero...');
    
    try {
      return await _tryImplicitFlow();
    } catch (e) {
      print('❌ Implicit Flow falló: $e');
      print('2. Probando PKCE Flow...');
      return await _tryPKCEFlow();
    }
    
  } catch (e) {
    print('🔴 Ambos flujos fallaron: $e');
    throw Exception(
      'Error con Google Sign-In:\n'
      '• Verifica las URIs en Google Cloud Console\n'
      '• Asegúrate de que https://web-pet-adopt.netlify.app/verify-email.html\n'
      '  esté en "Authorized redirect URIs"'
    );
  }
}

Future<UserModel> _tryImplicitFlow() async {
  print('🔄 Intentando Implicit Flow...');
  
  await supabaseClient.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'https://web-pet-adopt.netlify.app/verify-email.html',
    // Algunas versiones soportan esto para forzar Implicit:
    // authFlowType: AuthFlowType.implicit,
  );
  
  print('✅ Implicit Flow iniciado');
  print('   Los tokens deberían llegar en el HASH (#)');
  
  return await _waitForAuth(30, 'Implicit');
}

Future<UserModel> _tryPKCEFlow() async {
  print('🔄 Intentando PKCE Flow...');
  
  await supabaseClient.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'https://web-pet-adopt.netlify.app/oauth-callback.html',
    // PKCE es más común y confiable
    // authFlowType: AuthFlowType.pkce,
  );
  
  print('✅ PKCE Flow iniciado');
  print('   El código debería llegar en ?code=');
  
  return await _waitForAuth(40, 'PKCE');
}

Future<UserModel> _waitForAuth(int seconds, String flowName) async {
  print('⏳ Esperando $seconds segundos ($flowName)...');
  
  for (int i = 0; i < seconds; i++) {
    await Future.delayed(const Duration(seconds: 1));
    final user = supabaseClient.auth.currentUser;
    
    if (user != null) {
      print('🎉 ¡Autenticado con $flowName!');
      print('   Email: ${user.email}');
      print('   Tiempo: ${i + 1} segundos');
      return UserModel.fromSupabaseUser(user);
    }
    
    if (i % 10 == 0 && i > 0) {
      print('   $i/$seconds segundos - ¿Ya autorizaste?');
    }
  }
  
  throw Exception(
    'Timeout $flowName.\n'
    '¿Autorizaste con Google en el navegador?\n'
    '¿Volviste a la app después de autorizar?'
  );
}
}


