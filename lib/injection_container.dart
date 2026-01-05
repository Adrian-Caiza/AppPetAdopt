import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'injection_container.config.dart';

// Importa tus datasources
import 'features/pets/data/datasources/pet_remote_data_source.dart';

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

  // REGISTRO MANUAL DE PET DATASOURCE (Si @injectable falla o prefieres manual)
  // Nota: Si usas build_runner y @Injectable, esto se genera solo en injection_container.config.dart.
  // Pero asegúrate de correr: flutter pub run build_runner build
  
  // getIt.registerLazySingleton<PetRemoteDataSource>(
  //   () => PetRemoteDataSourceImpl(getIt<SupabaseClient>())
  // );

  // Initialize injectable (Generado)
  getIt.init();
}