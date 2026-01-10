import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/gemini_service.dart';
import 'core/network/network_info.dart';
// import 'injection_container.config.dart'; // Si usas build_runner

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

// Imports Adoption
import 'features/adoption/data/datasources/adoption_remote_data_source.dart';
import 'features/adoption/data/repositories/adoption_repository_impl.dart';
import 'features/adoption/domain/repositories/adoption_repository.dart';
import 'features/adoption/domain/usecases/submit_adoption_request.dart';
import 'features/adoption/presentation/bloc/adoption_bloc.dart';
import 'features/adoption/domain/usecases/get_shelter_requests.dart';
import 'features/adoption/domain/usecases/update_adoption_status.dart';
import 'features/adoption/domain/usecases/get_adopter_requests.dart'; // <--- NUEVO
import 'features/adoption/presentation/bloc/shelter_requests_bloc.dart';
import 'features/adoption/presentation/bloc/adopter_requests_bloc.dart'; // <--- NUEVO

// Imports Pets 
import 'features/pets/data/datasources/pet_remote_data_source.dart';
import 'features/pets/data/repositories/pet_repository_impl.dart';
import 'features/pets/domain/repositories/pet_repository.dart';
import 'features/pets/domain/usecases/add_pet.dart';
import 'features/pets/domain/usecases/get_pets.dart';
import 'features/pets/domain/usecases/get_shelter_pets.dart'; // <--- NUEVO
import 'features/pets/domain/usecases/delete_pet.dart';      // <--- NUEVO
import 'features/pets/domain/usecases/update_pet.dart';      // <--- NUEVO
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
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit, 
    ),
  );

  // =========================================================
  // 1. REGISTRO DE DEPENDENCIAS BÁSICAS Y EXTERNAS
  // =========================================================
  
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // NetworkInfo (Debe ir antes que los Repositories)
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>())
  );
  
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

  // =========================================================
  // 2. REGISTRO DE DATA SOURCES
  // =========================================================
  
  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>())
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
  // 3. REGISTRO DE REPOSITORIES (Inyectando NetworkInfo)
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
  // 4. REGISTRO DE USE CASES
  // =========================================================
  
  // --- Auth Use Cases ---
  getIt.registerLazySingleton<SignIn>(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignUp>(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ResetPassword>(() => ResetPassword(getIt<AuthRepository>()));
  
  // --- Adoption Use Cases ---
  getIt.registerLazySingleton<SubmitAdoptionRequest>(() => SubmitAdoptionRequest(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<GetShelterRequests>(() => GetShelterRequests(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<UpdateAdoptionStatus>(() => UpdateAdoptionStatus(getIt<AdoptionRepository>()));
  getIt.registerLazySingleton<GetAdopterRequests>(() => GetAdopterRequests(getIt<AdoptionRepository>())); // <--- NUEVO
  
  // --- Pets Use Cases ---
  getIt.registerLazySingleton<AddPet>(() => AddPet(getIt<PetRepository>()));
  getIt.registerLazySingleton<GetPets>(() => GetPets(getIt<PetRepository>()));
  getIt.registerLazySingleton<GetShelterPets>(() => GetShelterPets(getIt<PetRepository>())); // <--- NUEVO
  getIt.registerLazySingleton<DeletePet>(() => DeletePet(getIt<PetRepository>()));         // <--- NUEVO
  getIt.registerLazySingleton<UpdatePet>(() => UpdatePet(getIt<PetRepository>()));         // <--- NUEVO

  // --- Maps Use Cases ---
  getIt.registerLazySingleton<GetSheltersUseCase>(
    () => GetSheltersUseCase(getIt<MapsRepository>())
  );

  // =========================================================
  // 5. REGISTRO DE BLOCS
  // =========================================================
  
  // Auth Bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signIn: getIt<SignIn>(),
      signUp: getIt<SignUp>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      resetPassword: getIt<ResetPassword>(),
    ),
  );
  
  // Adoption: Crear solicitud
  getIt.registerFactory<AdoptionBloc>(
    () => AdoptionBloc(getIt<SubmitAdoptionRequest>())
  );
  
  // Adoption: Refugio Dashboard
  getIt.registerFactory<ShelterRequestsBloc>(
    () => ShelterRequestsBloc(
      getIt<GetShelterRequests>(),
      getIt<UpdateAdoptionStatus>(),
    )
  );

  // Adoption: Adoptante Mis Solicitudes (NUEVO)
  getIt.registerFactory<AdopterRequestsBloc>(
    () => AdopterRequestsBloc(
      getIt<GetAdopterRequests>()
    )
  );
  
  // Pet Bloc (ACTUALIZADO con nuevos use cases)
  getIt.registerFactory<PetBloc>(
    () => PetBloc(
      addPet: getIt<AddPet>(),
      getPets: getIt<GetPets>(),
      // Inyectamos los nuevos casos de uso que agregamos al constructor del Bloc
      getShelterPets: getIt<GetShelterPets>(),
      deletePet: getIt<DeletePet>(),
      updatePet: getIt<UpdatePet>(),
    )
  );

  // Map Bloc
  getIt.registerFactory<MapBloc>(
    () => MapBloc(getIt<GetSheltersUseCase>())
  );
  
  // getIt.init(); // Descomentar si usas generación de código automática
}