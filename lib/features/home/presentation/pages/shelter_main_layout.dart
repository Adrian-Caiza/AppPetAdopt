import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart'; // Para Logout
import '../../../auth/presentation/pages/login_page.dart';
import '../../../pets/presentation/pages/add_pet_page.dart';
import '../../../pets/presentation/pages/shelter_pets_page.dart'; // La crearemos abajo
import '../../../adoption/presentation/pages/shelter_requests_page.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../adoption/presentation/bloc/notification_bloc.dart';
import '../../../adoption/presentation/bloc/shelter_requests_bloc.dart';

class ShelterMainLayout extends StatefulWidget {
  final UserEntity user;
  const ShelterMainLayout({super.key, required this.user});

  @override
  State<ShelterMainLayout> createState() => _ShelterMainLayoutState();
}

class _ShelterMainLayoutState extends State<ShelterMainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      const ShelterPetsPage(), // Gestión de mascotas (Editar/Eliminar)
      const ShelterRequestsPage(), // Solicitudes
      _buildProfileTab(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<NotificationBloc>()..add(StartNotificationListening()),
        ),
        // Si necesitas acceder al Bloc de solicitudes desde aquí para recargarlo:
        BlocProvider(create: (_) => getIt<ShelterRequestsBloc>()), 
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationTriggered) {
            // 1. Mostrar Alerta Visual
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.teal,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'VER',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() => _currentIndex = 2); // Navegar a la pestaña de Solicitudes
                  },
                ),
              ),
            );

            // 2. Recargar datos automáticamente
            // Esto es clave: refrescamos la lista sin que el usuario haga nada
            context.read<ShelterRequestsBloc>().add(LoadShelterRequests());
          }
        },
      
        child: Scaffold(
          body: SafeArea(child: pages[_currentIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard), label: 'Inicio'),
              NavigationDestination(icon: Icon(Icons.pets), label: 'Mascotas'),
              NavigationDestination(icon: Icon(Icons.notifications), label: 'Solicitudes'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
          floatingActionButton: _currentIndex == 0 
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPetPage())),
                  child: const Icon(Icons.add),
                )
              : null,

        ),
      ),
    ); 
  }


  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Text(widget.user.displayName?[0].toUpperCase() ?? 'R', style: const TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, Refugio', style: Theme.of(context).textTheme.bodyLarge),
                  Text(widget.user.displayName ?? 'Sin Nombre', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          _buildSummaryCard(Icons.pets, 'Mascotas en Adopción', 'Gestiona tus publicaciones', 1),
          _buildSummaryCard(Icons.mark_email_unread, 'Solicitudes Pendientes', 'Revisar interesados', 2),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String title, String subtitle, int tabIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => setState(() => _currentIndex = tabIndex),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.store, size: 50)),
          const SizedBox(height: 16),
          Text(widget.user.displayName ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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