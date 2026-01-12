import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'injection_container.dart';
import 'core/network/network_info.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== INICIANDO APLICACIÓN ===');
  
  try {
    await dotenv.load(fileName: '.env');
    print('✓ .env cargado');
    
    await configureDependencies();
    print('✓ Dependencias configuradas');
    
    // Verifica que NetworkInfo esté registrado
    try {
      final networkInfo = getIt<NetworkInfo>();
      print('✓ NetworkInfo registrado correctamente');
    } catch (e) {
      print('✗ Error obteniendo NetworkInfo: $e');
    }
    
    runApp(const MyApp());
  } catch (e, stack) {
    print('✗ ERROR FATAL: $e');
    print(stack);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${e.toString()}', style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Login Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is AuthAuthenticated) {
              return WelcomePage(user: state.user);
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
