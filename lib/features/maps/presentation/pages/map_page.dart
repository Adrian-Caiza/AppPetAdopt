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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Línea decorativa superior
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.home_work_rounded, color: Colors.teal, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shelter.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (shelter.address != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(shelter.address!)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (shelter.phone != null) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(shelter.phone!),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí podrías navegar al perfil detallado del refugio
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('Ver Mascotas del Refugio'),
                ),
              )
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