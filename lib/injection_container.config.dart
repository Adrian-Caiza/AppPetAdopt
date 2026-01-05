// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_pet_adopt/core/network/network_info.dart' as _i847;
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
    gh.lazySingleton<_i296.AuthRepository>(
      () => _i990.AuthRepositoryImpl(
        remoteDataSource: gh<_i883.AuthRemoteDataSource>(),
        networkInfo: gh<_i847.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i63.PetRemoteDataSource>(
      () => _i63.PetRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
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
    gh.factory<_i330.AuthBloc>(
      () => _i330.AuthBloc(
        signIn: gh<_i656.SignIn>(),
        signUp: gh<_i611.SignUp>(),
        resetPassword: gh<_i676.ResetPassword>(),
        signOut: gh<_i854.SignOut>(),
        getCurrentUser: gh<_i338.GetCurrentUser>(),
      ),
    );
    return this;
  }
}
