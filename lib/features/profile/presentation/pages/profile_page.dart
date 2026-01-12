import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/update_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../maps/presentation/pages/location_picker_page.dart'; // Importamos el archivo que creamos en el Paso 1

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // Variables para el mapa (Solo Refugios)
  double? _latitude;
  double? _longitude;

  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carga los datos iniciales desde el AuthBloc
  void _loadUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _currentUser = state.user;
      
      _nameController = TextEditingController(text: _currentUser?.fullName ?? '');
      
      // Intentamos obtener teléfono y dirección. Si son nulos, texto vacío.
      _phoneController = TextEditingController(text: _currentUser?.phone ?? '');
      _addressController = TextEditingController(text: _currentUser?.address ?? '');

      // Extraer coordenadas de userMetadata (Supabase guarda esto en jsonb)
      // Ajusta las claves según como se llamen en tu BD
      final meta = _currentUser?.userMetadata ?? {};
      if (meta['latitude'] != null) _latitude = (meta['latitude'] as num).toDouble();
      if (meta['longitude'] != null) _longitude = (meta['longitude'] as num).toDouble();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Determina si es Refugio
  bool _isShelter() {
    return _currentUser?.userMetadata?['role'] == 'shelter';
  }

  // Abrir pantalla de mapa
  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  // Guardar en Base de Datos
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    // 1. Datos básicos
    final Map<String, dynamic> updates = {
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    // 2. Si es refugio, añadimos ubicación a la metadata o columnas directas
    // Depende de cómo tengas tu tabla. Asumamos que son columnas directas en 'profiles'
    if (_isShelter() && _latitude != null) {
      updates['latitude'] = _latitude;
      updates['longitude'] = _longitude;
    }

    // 3. Llamada al UseCase
    final updateUser = getIt<UpdateUser>();
    final result = await updateUser(_currentUser!.id, updates);

    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: Colors.red),
      ),
      (_) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
        );
        // IMPORTANTE: Recargar sesión para actualizar datos en toda la app
        context.read<AuthBloc>().add(CheckAuthStatusRequested());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris suave
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.teal),
            onPressed: () {
              setState(() {
                if (_isEditing) _loadUserData(); // Cancelar cambios
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- SECCIÓN 1: FOTO DE PERFIL ---
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: _currentUser?.avatarUrl != null
                          ? NetworkImage(_currentUser!.avatarUrl!)
                          : null,
                      child: _currentUser?.avatarUrl == null
                          ? Text(
                              _currentUser!.fullName.isNotEmpty 
                                ? _currentUser!.fullName[0].toUpperCase() 
                                : '?',
                              style: const TextStyle(fontSize: 40, color: Colors.teal),
                            )
                          : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.teal,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: () {
                            // Aquí iría la lógica de subir imagen
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _isShelter() ? 'Refugio Verificado' : 'Adoptante',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              // --- SECCIÓN 2: CAMPOS ---
              _buildInfoCard(
                label: 'Nombre Completo',
                controller: _nameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                label: 'Teléfono',
                controller: _phoneController,
                icon: Icons.phone,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                label: 'Dirección',
                controller: _addressController,
                icon: Icons.location_city,
                maxLines: 2,
              ),

              // --- SECCIÓN 3: MAPA (SOLO REFUGIOS) ---
              if (_isShelter()) ...[
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '📍 Ubicación en Mapa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isEditing ? _pickLocation : null, // Solo clicable al editar
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _isEditing ? Colors.teal : Colors.grey.shade300,
                        width: _isEditing ? 2 : 1
                      ),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Fondo visual (Placeholder o Mapa estático si quisieras implementarlo)
                          Container(color: Colors.grey[100]), 
                          
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined, 
                                size: 40, 
                                color: _latitude != null ? Colors.teal : Colors.grey
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _latitude != null 
                                    ? 'Ubicación Definida\nLat: ${_latitude!.toStringAsFixed(3)}...' 
                                    : 'Sin ubicación definida',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _latitude != null ? Colors.teal.shade700 : Colors.grey,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                          
                          if (_isEditing)
                            Container(
                              color: Colors.black12,
                              child: const Center(
                                child: Chip(
                                  label: Text('Tocar para cambiar'),
                                  avatar: Icon(Icons.edit_location),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // --- BOTÓN GUARDAR ---
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  ),
                ),
                
              // Botón de Cerrar Sesión (Siempre visible al fondo)
              if (!_isEditing) ...[
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para diseño limpio de Inputs
  Widget _buildInfoCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (val) => val!.isEmpty ? 'Campo requerido' : null,
        style: TextStyle(
          color: _isEditing ? Colors.black87 : Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _isEditing ? Colors.teal : Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // Borde sutil solo cuando está habilitado
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(15),
             borderSide: BorderSide(color: Colors.transparent),
          ),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[50],
        ),
      ),
    );
  }
}