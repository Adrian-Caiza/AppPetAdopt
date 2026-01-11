import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../pets/presentation/pages/pet_feed_page.dart';
import '../../../maps/presentation/pages/map_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../adoption/presentation/pages/adopter_requests_page.dart'; 
import '../../../adoption/presentation/bloc/notification_bloc.dart';
import '../../../adoption/presentation/bloc/adopter_requests_bloc.dart';
import '../../../../injection_container.dart';

class AdopterMainLayout extends StatefulWidget {
  final UserEntity user;
  const AdopterMainLayout({super.key, required this.user});

  @override
  State<AdopterMainLayout> createState() => _AdopterMainLayoutState();
}

class _AdopterMainLayoutState extends State<AdopterMainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Construimos las páginas. Pasamos 'showAppBar: false' a PetFeed si es necesario para evitar doble AppBar
    final pages = [
      const PetFeedPage(), // Inicio
      const MapPage(),     // Mapa
      const ChatPage(),    // Chat IA
      const AdopterRequestsPage(), // Solicitudes
      _buildProfileTab(),  // Perfil
    ];
    return MultiBlocProvider(
      providers: [
        // 1. Inyectamos el Bloc de Notificaciones
        BlocProvider(
          create: (_) => getIt<NotificationBloc>()..add(StartNotificationListening()),
        ),
        // 2. (Opcional) Si tienes un Bloc que muestra "Mis Solicitudes", agrégalo aquí
        BlocProvider(create: (_) => getIt<AdopterRequestsBloc>()..add(LoadAdopterRequests())),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationTriggered) {
            // Lógica de colores según si es Aprobado (Verde) o Rechazado (Rojo)
            final bgColor = state.isSuccess ? Colors.teal : Colors.redAccent;
            final icon = state.isSuccess ? Icons.check_circle : Icons.cancel;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4), // Duralo un poco más para que lo lean
                action: SnackBarAction(
                  label: 'VER ESTADO',
                  textColor: Colors.white,
                  onPressed: () {
                     // Navegar a la pestaña de "Mis Solicitudes" si la tienes
                      setState(() => _currentIndex = 1); 
                  },
                ),
              ),
            );

            // IMPORTANTE: Recargar la lista de solicitudes para ver el cambio de estado
            context.read<AdopterRequestsBloc>().add(LoadAdopterRequests());
          }
        },

        child: Scaffold(
          // Usamos IndexedStack para mantener el estado de las páginas (como el scroll o el mapa)
          body: Builder(
            builder: (context) {
              // Si estamos en Mapa (1) o Chat (2), usamos IndexedStack para guardar su estado
              if (_currentIndex == 1 || _currentIndex == 2) {
                  return IndexedStack(
                    index: _currentIndex,
                    children: pages, // Mantiene todo vivo, pero solo vemos el seleccionado
                  );
              }
              
              // Para Inicio, Solicitudes y Perfil: Devolvemos la página directamente.
              // Esto fuerza a que se ejecute "initState" y recargue los datos cada vez.
              return pages[_currentIndex];
            },
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
              NavigationDestination(icon: Icon(Icons.map), label: 'Mapa'),
              NavigationDestination(icon: Icon(Icons.smart_toy), label: 'IA'),
              NavigationDestination(icon: Icon(Icons.history), label: 'Solicitudes'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _buildProfileTab() {
    // Reutiliza el diseño de perfil del refugio o crea uno similar
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Text(widget.user.displayName ?? 'Adoptante', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(widget.user.email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          )
        ],
      ),
    );
  }
}