import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'email_verification_sent_page.dart';
import 'welcome_page.dart';
import 'location_picker_page.dart';
import 'package:latlong2/latlong.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController(); // Nuevo
  final _phoneController = TextEditingController();   // Nuevo
  
  double? _latitude;
  double? _longitude;
  // Variable para el rol (Por defecto Adoptante)
  String _selectedRole = 'adopter'; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickLocationFromMap() async {
    // Navegamos a la pantalla del mapa y esperamos el resultado (LatLng)
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    // Si el usuario confirmó una ubicación (no regresó con "atrás")
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      
      // Opcional: Podrías intentar obtener la dirección textual de esas coordenadas
      // usando un servicio de Geocoding aquí, pero por ahora solo guardamos coords.
    }
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == 'shelter' && _latitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor guarda la ubicación del refugio.'))
          );
          return;
      }
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim(),
              role: _selectedRole, // Enviamos el rol seleccionado
              address: _selectedRole == 'shelter' ? _addressController.text.trim() : null,
              phone: _selectedRole == 'shelter' ? _phoneController.text.trim() : null,
              latitude: _selectedRole == 'shelter' ? _latitude : null,
              longitude: _selectedRole == 'shelter' ? _longitude : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is EmailVerificationRequired) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EmailVerificationSentPage(email: state.email),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => WelcomePage(user: state.user),
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¿Quién eres?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Selector de Roles (Card selection)
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            'Adoptante', 
                            'adopter', 
                            Icons.home_rounded,
                            Colors.orange
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            'Refugio', 
                            'shelter', 
                            Icons.local_hospital_rounded,
                            Colors.teal
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    CustomTextField(
                      controller: _nameController,
                      label: _selectedRole == 'shelter' ? 'Nombre del Refugio' : 'Nombre completo',
                      hint: _selectedRole == 'shelter' ? 'Ej: Patitas Felices' : 'Ej: Juan Pérez', // <--- CORREGIDO: Se agregó hint
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'tu@email.com', // <--- CORREGIDO: Se agregó hint
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: '••••••••', // <--- CORREGIDO: Se agregó hint
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar contraseña',
                      hint: '••••••••', // <--- CORREGIDO: Se agregó hint
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => v != _passwordController.text ? 'No coinciden' : null,
                    ),
                    if (_selectedRole == 'shelter') ...[

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text("Datos del Refugio", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                          controller: _addressController,
                          label: 'Dirección física',
                          hint: 'Av. Principal 123',
                          prefixIcon: Icons.location_city,
                          validator: (v) => v!.isEmpty ? 'Requerido para el mapa' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                          controller: _phoneController,
                          label: 'Teléfono de contacto',
                          hint: '0991234567',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Requerido para contacto' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Botón de Ubicación
                      GestureDetector(
                          onTap: _pickLocationFromMap, // <--- Llama a la nueva función
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _latitude != null ? Colors.teal : Colors.grey,
                                width: 2
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _latitude != null ? Colors.teal.withOpacity(0.05) : Colors.grey[100],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _latitude != null ? Icons.map : Icons.add_location_alt_outlined,
                                  color: _latitude != null ? Colors.teal : Colors.grey[600],
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _latitude != null ? 'Ubicación Definida' : 'Definir Ubicación en Mapa',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _latitude != null ? Colors.teal : Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_latitude != null)
                                        Text(
                                          'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        )
                                      else
                                        Text(
                                          'Toca para abrir el mapa y colocar el pin',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedRole == 'shelter' && _latitude == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 12),
                            child: Text(
                              '* La ubicación en el mapa es obligatoria',
                              style: TextStyle(color: Colors.red[700], fontSize: 12),
                            ),
                          ),  
                      ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(String title, String value, IconData icon, Color color) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}