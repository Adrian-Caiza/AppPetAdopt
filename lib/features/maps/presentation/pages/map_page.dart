

FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(-0.1807, -78.4678), // Coordenadas ejemplo (Quito)
    initialZoom: 13.0,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', 
      userAgentPackageName: 'com.example.app_pet_adopt',
    ),
    MarkerLayer(
      markers: [
        // Marcador del usuario
        Marker(
          point: userLocation,
          child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        ),
        // Marcadores de Refugios (Iterar tu lista de refugios)
        // Datos quemados para validar [cite: 90]
        Marker(
          point: LatLng(-0.1700, -78.4700),
          child: Icon(Icons.home_work, color: Colors.orange, size: 40),
        ),
      ],
    ),
  ],
);