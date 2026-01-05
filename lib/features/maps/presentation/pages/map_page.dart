import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;
  bool _isLoading = true;

  // Datos quemados para validar funcionalidad como pide el doc [cite: 90]
  final List<Marker> _shelterMarkers = [
    Marker(
      point: const LatLng(-0.1700, -78.4700), // Ejemplo Quito Norte
      width: 40,
      height: 40,
      child: const Icon(Icons.home_work, color: Colors.orange, size: 40),
    ),
    Marker(
      point: const LatLng(-0.1900, -78.4900), // Ejemplo Quito Sur
      width: 40,
      height: 40,
      child: const Icon(Icons.pets, color: Colors.green, size: 40),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentPosition == null) {
      return const Scaffold(body: Center(child: Text('Permiso de ubicación denegado')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Refugios Cercanos')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app_pet_adopt',
          ),
          MarkerLayer(
            markers: [
              // Tu ubicación
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
              ),
              ..._shelterMarkers, // Marcadores quemados
            ],
          ),
        ],
      ),
    );
  }
}