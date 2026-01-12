import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/gemini_service.dart';
import 'core/network/network_info.dart';

// Imports Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/reset_password.dart'; 
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/update_user.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';

// Imports Adoption
import 'features/adoption/data/datasources/adoption_remote_data_source.dart';
import 'features/adoption/data/repositories/adoption_repository_impl.dart';
import 'features/adoption/domain/repositories/adoption_repository.dart';
import 'features/adoption/domain/usecases/submit_adoption_request.dart';
import 'features/adoption/presentation/bloc/adoption_bloc.dart';
import 'features/adoption/domain/usecases/get_shelter_requests.dart';
import 'features/adoption/domain/usecases/update_adoption_status.dart';
import 'features/adoption/domain/usecases/get_adopter_requests.dart';
import 'features/adoption/presentation/bloc/shelter_requests_bloc.dart';
import 'features/adoption/presentation/bloc/adopter_requests_bloc.dart';
import 'features/adoption/domain/usecases/watch_adoption_notifications.dart';
import 'features/adoption/presentation/bloc/notification_bloc.dart';

// Imports Pets 
import 'features/pets/data/datasources/pet_remote_data_source.dart';
import 'features/pets/data/repositories/pet_repository_impl.dart';
import 'features/pets/domain/repositories/pet_repository.dart';
import 'features/pets/domain/usecases/add_pet.dart';
import 'features/pets/domain/usecases/get_pets.dart';
import 'features/pets/domain/usecases/get_shelter_pets.dart';
import 'features/pets/domain/usecases/delete_pet.dart';
import 'features/pets/domain/usecases/update_pet.dart';
import 'features/pets/presentation/bloc/pet_bloc.dart';

// Imports Maps
import 'features/maps/data/datasources/maps_remote_data_source.dart';
import 'features/maps/data/repositories/maps_repository_impl.dart';
import 'features/maps/domain/repositories/maps_repository.dart';
import 'features/maps/domain/usecases/get_shelters_usecase.dart';
import 'features/maps/presentation/bloc/map_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  
  // 1. LIMPIEZA DE MEMORIA (Crucial para evitar errores en Hot Restart)
  await getIt.reset(); 

  // 2. Inicializar Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit, 
      ),
    );
  } catch (e) {
    // Ignoramos si ya está inicializado
  }

  // =========================================================
  // 3. REGISTRO DE DEPENDENCIAS BÁSICAS Y EXTERNAS
  // =========================================================
  
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>())
  );
  
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

  // CONFIGURACIÓN DE GOOGLE SIGN IN
  // IMPORTANTE: Reemplaza 'TU_WEB_CLIENT_ID...' con tu ID real
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(
    serverClientId: 'TU_WEB_CLIENT_ID.apps.googleusercontent.com', 
    scopes: ['email', 'profile'],
  ));

  // =========================================================
  // 4. REGISTRO DE DATA SOURCES
  // =========================================================
  
  // Auth Data Source (Solo registrado UNA vez)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      getIt<SupabaseClient>(),
      // Si actualizaste el constructor de AuthRemoteDataSourceImpl para recibir GoogleSignIn,
      // descomenta la siguiente línea:
      // googleSignIn: getIt<GoogleSignIn>(), 
    )
  );
  
  // Adoption
  getIt.registerLazySingleton<AdoptionRemoteDataSource>(
    () => AdoptionRemoteDataSourceImpl(getIt<SupabaseClient>())
  );
  
  // Pets
  getIt.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSourceImpl(getIt<SupabaseClient>())
  );

  // Maps
  getIt.registerLazySingleton<MapsRemoteDataSource>(
    () => MapsRemoteDataSourceImpl(getIt<SupabaseClient>())
  );

  // =========================================================
  // 5. REGISTRO DE REPOSITORIES
  // =========================================================
  
  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );
  
  // Adoption
  getIt.registerLazySingleton<AdoptionRepository>(
    () => AdoptionRepositoryImpl(
      remoteDataSource: getIt<AdoptionRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );
  
  // Pets
  getIt.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(
      remoteDataSource: getIt<PetRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    )
  );

  // Maps
  getIt.registerLazySingleton<MapsRepository>(
    () => MapsRepositoryImpl(getIt<MapsRemoteDataSource>())
  );

  // =========================================================
  // 6. REGISTRO DE USE CASES
  // =========================================================
  
  // --- Auth Use Cases ---
  getIt.registerLazySingleton<SignIn>(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignUp>(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ResetPassword>(() => ResetPassword(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(getIt<AuthRepository>()));
  
  // Perfil y Estado
  getIt.registerLazySingleton<CheckAuthStatus>(() => CheckAuthStatus(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdateUser>(() => UpdateUser(getIt<AuthRepository>()));
  
  // --- Adoption Use Cases ---
  getIt.registerLazySingleton<SubmitAdoptionRequest>(() => SubmitAdoptionRequest(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<GetShelterRequests>(() => GetShelterRequests(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<UpdateAdoptionStatus>(() => UpdateAdoptionStatus(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<GetAdopterRequests>(() => GetAdopterRequests(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<WatchAdoptionNotifications>(() => WatchAdoptionNotifications(getIt<AdoptionRepository>()));
  
  // --- Pets Use Cases ---
  getIt.registerLazySingleton<AddPet>(() => AddPet(getIt<PetRepository>()));
  getIt.registerLazySingleton<GetPets>(() => GetPets(getIt<PetRepository>()));
  getIt.registerLazySingleton<GetShelterPets>(() => GetShelterPets(getIt<PetRepository>()));
  getIt.registerLazySingleton<DeletePet>(() => DeletePet(getIt<PetRepository>()));
  getIt.registerLazySingleton<UpdatePet>(() => UpdatePet(getIt<PetRepository>()));

  // --- Maps Use Cases ---
  getIt.registerLazySingleton<GetSheltersUseCase>(
    () => GetSheltersUseCase(getIt<MapsRepository>())
  );

  // =========================================================
  // 7. REGISTRO DE BLOCS
  // =========================================================
  
  // Auth Bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signIn: getIt<SignIn>(),
      signUp: getIt<SignUp>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      resetPassword: getIt<ResetPassword>(),
      checkAuthStatus: getIt<CheckAuthStatus>(),
    ),
  );
  
  // Adoption Blocs
  getIt.registerFactory<AdoptionBloc>(
    () => AdoptionBloc(getIt<SubmitAdoptionRequest>())
  );
  
  getIt.registerFactory<ShelterRequestsBloc>(
    () => ShelterRequestsBloc(
      getIt<GetShelterRequests>(),
      getIt<UpdateAdoptionStatus>(),
    )
  );

  getIt.registerFactory<AdopterRequestsBloc>(
    () => AdopterRequestsBloc(
      getIt<GetAdopterRequests>()
    )
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getIt<WatchAdoptionNotifications>(), 
      getIt<GetCurrentUser>()
    )
  );
  
  // Pet Bloc
  getIt.registerFactory<PetBloc>(
    () => PetBloc(
      addPet: getIt<AddPet>(),
      getPets: getIt<GetPets>(),
      getShelterPets: getIt<GetShelterPets>(),
      deletePet: getIt<DeletePet>(),
      updatePet: getIt<UpdatePet>(),
    )
  );

  // Map Bloc
  getIt.registerFactory<MapBloc>(
    () => MapBloc(getIt<GetSheltersUseCase>())
  );
}