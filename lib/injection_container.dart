import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'injection_container.config.dart';
import 'core/services/gemini_service.dart';

// Imports Adoption
import 'features/adoption/data/datasources/adoption_remote_data_source.dart';
import 'features/adoption/data/repositories/adoption_repository_impl.dart';
import 'features/adoption/domain/repositories/adoption_repository.dart';
import 'features/adoption/domain/usecases/submit_adoption_request.dart';
import 'features/adoption/presentation/bloc/adoption_bloc.dart';
import 'features/adoption/domain/usecases/get_shelter_requests.dart';
import 'features/adoption/domain/usecases/update_adoption_status.dart';
import 'features/adoption/presentation/bloc/shelter_requests_bloc.dart';

// Imports Pets 
import 'features/pets/data/datasources/pet_remote_data_source.dart';
import 'features/pets/data/repositories/pet_repository_impl.dart';
import 'features/pets/domain/repositories/pet_repository.dart';
import 'features/pets/domain/usecases/add_pet.dart';
import 'features/pets/domain/usecases/get_pets.dart';
import 'features/pets/presentation/bloc/pet_bloc.dart';

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

  // Register external dependencies
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());
  // Adoption Feature
  getIt.registerLazySingleton<AdoptionRemoteDataSource>(() => AdoptionRemoteDataSourceImpl(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<AdoptionRepository>(() => AdoptionRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()));
  getIt.registerLazySingleton<SubmitAdoptionRequest>(() => SubmitAdoptionRequest(getIt()));
  getIt.registerFactory<AdoptionBloc>(() => AdoptionBloc(getIt()));
  getIt.registerLazySingleton<GetShelterRequests>(() => GetShelterRequests(getIt()));
  getIt.registerLazySingleton<UpdateAdoptionStatus>(() => UpdateAdoptionStatus(getIt()));
  getIt.registerFactory<ShelterRequestsBloc>(() => ShelterRequestsBloc(getIt(), getIt()),);
  // --- FEATURE: PETS  ---
  getIt.registerLazySingleton<PetRemoteDataSource>(() => PetRemoteDataSourceImpl(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<PetRepository>(() => PetRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()));
  getIt.registerLazySingleton<AddPet>(() => AddPet(getIt()));
  getIt.registerLazySingleton<GetPets>(() => GetPets(getIt()));
  getIt.registerFactory<PetBloc>(() => PetBloc(addPet: getIt(), getPets: getIt()),);

  // REGISTRO MANUAL DE PET DATASOURCE (Si @injectable falla o prefieres manual)
  // Nota: Si usas build_runner y @Injectable, esto se genera solo en injection_container.config.dart.
  // Pero asegúrate de correr: flutter pub run build_runner build
  
  // getIt.registerLazySingleton<PetRemoteDataSource>(
  //   () => PetRemoteDataSourceImpl(getIt<SupabaseClient>())
  // );

  // Initialize injectable (Generado)
  getIt.init();
}