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

    return Scaffold(
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