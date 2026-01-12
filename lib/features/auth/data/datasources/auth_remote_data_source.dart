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
    print('🚀 Iniciando Google Sign-In (OAuthProvider.google)...');
    
    // Configuración CORRECTA para Implicit Flow
    await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google, // ✅ Esto funciona en tu versión
      redirectTo: 'https://web-pet-adopt.netlify.app/verify-email.html',
    );
    
    print('✅ Redirigiendo a Google...');
    print('📱 Con Implicit Flow:');
    print('   1. Te redirigirá a nuestra página Netlify');
    print('   2. La página procesará los tokens');
    print('   3. Te redirigirá de vuelta a la app automáticamente');
    
    // Espera inteligente para Implicit Flow
    return await _waitForImplicitFlow();
    
  } on AuthException catch (e) {
    print('🔴 Error de autenticación: ${e.message}');
    throw Exception('Error de Google: ${e.message}');
  } catch (e, stack) {
    print('🔴 Error inesperado: $e');
    print('Stack: $stack');
    throw Exception('Error al conectar con Google: $e');
  }
}

Future<UserModel> _waitForImplicitFlow() async {
  print('⏳ Esperando procesamiento de Implicit Flow...');
  print('   Esto puede tomar hasta 60 segundos');
  print('   Por favor NO cierres la app');
  
  const totalWait = 60; // 60 segundos máximo
  int secondsWaited = 0;
  
  while (secondsWaited < totalWait) {
    await Future.delayed(const Duration(seconds: 1));
    secondsWaited++;
    
    final currentUser = supabaseClient.auth.currentUser;
    
    if (currentUser != null) {
      print('🎉 ¡AUTENTICACIÓN EXITOSA!');
      print('   Tiempo: $secondsWaited segundos');
      print('   Usuario: ${currentUser.email}');
      print('   ID: ${currentUser.id}');
      return UserModel.fromSupabaseUser(currentUser);
    }
    
    // Mostrar progreso
    if (secondsWaited % 10 == 0) {
      print('   ⏳ $secondsWaited/$totalWait segundos...');
      if (secondsWaited >= 20) {
        print('   💡 ¿Ya autorizaste con Google en el navegador?');
        print('   💡 ¿La página te redirigió de vuelta a la app?');
      }
    }
  }
  
  print('⚠️ Timeout después de $totalWait segundos');
  print('   Esto es NORMAL si:');
  print('   1. No completaste la autorización en el navegador');
  print('   2. No volviste a la app después de autorizar');
  print('   3. Hay problemas con los deep links');
  
  throw Exception(
    'Por favor:\n'
    '1. Completa la autorización con Google en el navegador\n'
    '2. Espera a que te redirija de vuelta a la app\n'
    '3. Si no se abre automáticamente, vuelve MANUALMENTE\n'
    '4. Tu sesión se activará automáticamente'
  );
}
}


