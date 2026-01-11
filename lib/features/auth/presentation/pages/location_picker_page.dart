import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(-0.1807, -78.4678); // Default: Quito
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Obtenemos la ubicación inicial del usuario para centrar el mapa ahí
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Servicios desactivados');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permisos denegados');
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      // Movemos el mapa a la ubicación actual
      _mapController.move(_currentCenter, 15.0);
    } catch (e) {
      // Si falla, solo dejamos de cargar y usa la ubicación por defecto
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Define la ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Devolvemos la coordenada central al cerrar la pantalla
              Navigator.pop(context, _currentCenter);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              // Cada vez que se mueve el mapa, actualizamos la coordenada central
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  setState(() {
                    _currentCenter = position.center!;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_pet_adopt',
              ),
            ],
          ),
          
          // El PIN fijo en el centro de la pantalla
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Ajuste visual para que la punta del pin sea el centro
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),

          // Botón para volver a mi ubicación GPS
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'gps_btn',
              child: const Icon(Icons.my_location),
              onPressed: () async {
                  setState(() => _isLoading = true);
                  await _determinePosition();
              },
            ),
          ),

          // Botón inferior de confirmar
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context, _currentCenter);
              },
              child: const Text(
                'CONFIRMAR ESTA UBICACIÓN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }
}