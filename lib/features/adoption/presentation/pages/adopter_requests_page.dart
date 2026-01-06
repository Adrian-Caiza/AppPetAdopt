import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../bloc/adopter_requests_bloc.dart'; // Asegúrate de importar el Bloc correcto

class AdopterRequestsPage extends StatelessWidget {
  const AdopterRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Inyectamos el Bloc y cargamos las solicitudes al iniciar
      create: (_) => getIt<AdopterRequestsBloc>()..add(LoadAdopterRequests()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Solicitudes'),
        ),
        body: BlocBuilder<AdopterRequestsBloc, AdopterRequestsState>(
          builder: (context, state) {
            if (state is AdopterRequestsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdopterRequestsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Ocurrió un error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (state is AdopterRequestsLoaded) {
              if (state.requests.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  return _AdoptionRequestCard(request: state.requests[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aún no has solicitado adopciones.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('¡Ve al inicio y busca a tu compañero ideal!'),
        ],
      ),
    );
  }
}

class _AdoptionRequestCard extends StatelessWidget {
  final AdoptionRequestEntity request;

  const _AdoptionRequestCard({required this.request});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '¡APROBADO!';
      case 'rejected':
        return 'RECHAZADO';
      default:
        return 'PENDIENTE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(request.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Encabezado de la Tarjeta (Mascota y Estado)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto de la mascota
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: request.petPhoto != null
                        ? Image.network(request.petPhoto!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.pets, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.petName ?? 'Mascota Desconocida',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enviado el: ${_formatDate(request.createdAt)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Badge de Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Mensaje que enviaste
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tu mensaje:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '"${request.message}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    return '${date.day}/${date.month}/${date.year}';
  }
}