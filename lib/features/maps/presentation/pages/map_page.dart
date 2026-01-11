import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../injection_container.dart'; 
import '../bloc/map_bloc.dart';
import '../../domain/entities/shelter_map_entity.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveemos el MapBloc al árbol de widgets
    return BlocProvider(
      create: (_) => getIt<MapBloc>()..add(LoadMapShelters()),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // ... (Tu lógica de geolocator existente se mantiene igual) ...
    // Para abreviar, uso una implementación simple aquí:
    try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Servicios desactivados');
        
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) throw Exception('Permisos denegados');
        }
        
        Position position = await Geolocator.getCurrentPosition();
        if(mounted) {
            setState(() {
                _currentPosition = LatLng(position.latitude, position.longitude);
                _isLoadingLocation = false;
            });
        }
    } catch (e) {
        if(mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showShelterInfo(BuildContext context, ShelterMapEntity shelter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Permite que se ajuste mejor al contenido
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          // Añadimos padding inferior para evitar conflictos con la barra de navegación del sistema
          padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Indicador de arrastre (Barra gris pequeña)
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Título (Nombre del Refugio)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pets, color: Colors.teal, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      shelter.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // 3. Dirección
              if (shelter.address != null && shelter.address!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dirección:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          Text(
                            shelter.address!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 4. TELÉFONO (Agregado aquí)
              if (shelter.phone != null && shelter.phone!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Teléfono de contacto:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              shelter.phone!,
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 5. Botón de Acción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Aquí podrías navegar al perfil completo del refugio más adelante
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver Mascotas Disponibles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ubicación por defecto (ej. Quito) si falla el GPS
    final initialCenter = _currentPosition ?? const LatLng(-0.1807, -78.4678);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Refugios')),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          List<Marker> markers = [];

          // 1. Marcador de Usuario
          if (_currentPosition != null) {
            markers.add(
              Marker(
                point: _currentPosition!,
                width: 50,
                height: 50,
                child: const Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 40),
              ),
            );
          }

          // 2. Marcadores de Refugios (Dinámicos)
          if (state is MapLoaded) {
            markers.addAll(state.shelters.map((shelter) {
              return Marker(
                point: LatLng(shelter.latitude, shelter.longitude),
                width: 50,
                height: 50,
                // Usamos GestureDetector para detectar el tap
                child: GestureDetector(
                  onTap: () => _showShelterInfo(context, shelter),
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              );
            }));
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_pet_adopt',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      // Botón flotante para recentrar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            if(_currentPosition != null) {
                _mapController.move(_currentPosition!, 15.0);
            }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}