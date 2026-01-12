import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Pega aquí TU CLIENTE WEB si pruebas en Web, o iOS si pruebas en iOS
    serverClientId: '432958566682-mpedq2uqesklm28jrcla6rqdakiunccb.apps.googleusercontent.com', 
  );

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
      // 1. Iniciar flujo nativo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      // 2. Obtener tokens de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google');
      }

      // 3. Iniciar sesión en Supabase con esos tokens
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Error al iniciar sesión con Google en Supabase');
      }

      // 4. (Opcional) Guardar datos extra en la tabla profiles si es usuario nuevo
      // Esto lo hace tu Trigger de base de datos automáticamente, 
      // pero el avatar de Google viene en user_metadata['avatar_url']

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }
  }
}