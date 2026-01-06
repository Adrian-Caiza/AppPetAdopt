import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
// import '../../../pets/presentation/pages/pet_feed_page.dart'; 
// import 'shelter_home_page.dart'; 
import '../../../home/presentation/pages/shelter_main_layout.dart';
import '../../../home/presentation/pages/adopter_main_layout.dart';

class WelcomePage extends StatefulWidget {
  final UserEntity user;

  const WelcomePage({super.key, required this.user});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Redirección automática después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnRole();
    });
  }

  void _navigateBasedOnRole() {
    // Obtenemos el rol de la metadata de Supabase
    final role = widget.user.userMetadata?['role'] ?? 'adopter';

    if (role == 'shelter') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ShelterMainLayout(user: widget.user)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AdopterMainLayout(user: widget.user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Iniciando sesión...'),
          ],
        ),
      ),
    );
  }
}