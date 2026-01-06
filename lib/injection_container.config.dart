// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_pet_adopt/core/network/network_info.dart' as _i847;
import 'package:app_pet_adopt/features/adoption/data/datasources/adoption_remote_data_source.dart'
    as _i475;
import 'package:app_pet_adopt/features/adoption/data/repositories/adoption_repository_impl.dart'
    as _i824;
import 'package:app_pet_adopt/features/adoption/domain/repositories/adoption_repository.dart'
    as _i1069;
import 'package:app_pet_adopt/features/adoption/domain/usecases/get_shelter_requests.dart'
    as _i41;
import 'package:app_pet_adopt/features/adoption/domain/usecases/submit_adoption_request.dart'
    as _i427;
import 'package:app_pet_adopt/features/adoption/domain/usecases/update_adoption_status.dart'
    as _i327;
import 'package:app_pet_adopt/features/adoption/presentation/bloc/adoption_bloc.dart'
    as _i776;
import 'package:app_pet_adopt/features/adoption/presentation/bloc/shelter_requests_bloc.dart'
    as _i981;
import 'package:app_pet_adopt/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i883;
import 'package:app_pet_adopt/features/auth/data/repositories/auth_repository_impl.dart'
    as _i990;
import 'package:app_pet_adopt/features/auth/domain/repositories/auth_repository.dart'
    as _i296;
import 'package:app_pet_adopt/features/auth/domain/usecases/get_current_user.dart'
    as _i338;
import 'package:app_pet_adopt/features/auth/domain/usecases/reset_password.dart'
    as _i676;
import 'package:app_pet_adopt/features/auth/domain/usecases/sign_in.dart'
    as _i656;
import 'package:app_pet_adopt/features/auth/domain/usecases/sign_out.dart'
    as _i854;
import 'package:app_pet_adopt/features/auth/domain/usecases/sign_up.dart'
    as _i611;
import 'package:app_pet_adopt/features/auth/presentation/bloc/auth_bloc.dart'
    as _i330;
import 'package:app_pet_adopt/features/pets/data/datasources/pet_remote_data_source.dart'
    as _i63;
import 'package:app_pet_adopt/features/pets/data/repositories/pet_repository_impl.dart'
    as _i481;
import 'package:app_pet_adopt/features/pets/domain/repositories/pet_repository.dart'
    as _i1036;
import 'package:app_pet_adopt/features/pets/domain/usecases/add_pet.dart'
    as _i454;
import 'package:app_pet_adopt/features/pets/domain/usecases/get_pets.dart'
    as _i5;
import 'package:app_pet_adopt/features/pets/presentation/bloc/pet_bloc.dart'
    as _i351;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i883.AuthRemoteDataSource>(
      () => _i883.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i847.NetworkInfo>(
      () => _i847.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i475.AdoptionRemoteDataSource>(
      () => _i475.AdoptionRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i296.AuthRepository>(
      () => _i990.AuthRepositoryImpl(
        remoteDataSource: gh<_i883.AuthRemoteDataSource>(),
        networkInfo: gh<_i847.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i63.PetRemoteDataSource>(
      () => _i63.PetRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1036.PetRepository>(
      () => _i481.PetRepositoryImpl(
        remoteDataSource: gh<_i63.PetRemoteDataSource>(),
        networkInfo: gh<_i847.NetworkInfo>(),
      ),
    );
    gh.factory<_i338.GetCurrentUser>(
      () => _i338.GetCurrentUser(gh<_i296.AuthRepository>()),
    );
    gh.factory<_i676.ResetPassword>(
      () => _i676.ResetPassword(gh<_i296.AuthRepository>()),
    );
    gh.factory<_i656.SignIn>(() => _i656.SignIn(gh<_i296.AuthRepository>()));
    gh.factory<_i854.SignOut>(() => _i854.SignOut(gh<_i296.AuthRepository>()));
    gh.factory<_i611.SignUp>(() => _i611.SignUp(gh<_i296.AuthRepository>()));
    gh.lazySingleton<_i1069.AdoptionRepository>(
      () => _i824.AdoptionRepositoryImpl(
        remoteDataSource: gh<_i475.AdoptionRemoteDataSource>(),
        networkInfo: gh<_i847.NetworkInfo>(),
      ),
    );
    gh.factory<_i330.AuthBloc>(
      () => _i330.AuthBloc(
        signIn: gh<_i656.SignIn>(),
        signUp: gh<_i611.SignUp>(),
        resetPassword: gh<_i676.ResetPassword>(),
        signOut: gh<_i854.SignOut>(),
        getCurrentUser: gh<_i338.GetCurrentUser>(),
      ),
    );
    gh.lazySingleton<_i41.GetShelterRequests>(
      () => _i41.GetShelterRequests(gh<_i1069.AdoptionRepository>()),
    );
    gh.lazySingleton<_i427.SubmitAdoptionRequest>(
      () => _i427.SubmitAdoptionRequest(gh<_i1069.AdoptionRepository>()),
    );
    gh.lazySingleton<_i327.UpdateAdoptionStatus>(
      () => _i327.UpdateAdoptionStatus(gh<_i1069.AdoptionRepository>()),
    );
    gh.lazySingleton<_i454.AddPet>(
      () => _i454.AddPet(gh<_i1036.PetRepository>()),
    );
    gh.lazySingleton<_i5.GetPets>(
      () => _i5.GetPets(gh<_i1036.PetRepository>()),
    );
    gh.factory<_i776.AdoptionBloc>(
      () => _i776.AdoptionBloc(gh<_i427.SubmitAdoptionRequest>()),
    );
    gh.factory<_i981.ShelterRequestsBloc>(
      () => _i981.ShelterRequestsBloc(
        gh<_i41.GetShelterRequests>(),
        gh<_i327.UpdateAdoptionStatus>(),
      ),
    );
    gh.factory<_i351.PetBloc>(
      () =>
          _i351.PetBloc(addPet: gh<_i454.AddPet>(), getPets: gh<_i5.GetPets>()),
    );
    return this;
  }
}
