import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/adoption_request_entity.dart';
import '../bloc/shelter_requests_bloc.dart';

class ShelterRequestsPage extends StatelessWidget {
  const ShelterRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShelterRequestsBloc>()..add(LoadShelterRequests()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Solicitudes Recibidas')),
        body: BlocBuilder<ShelterRequestsBloc, ShelterRequestsState>(
          builder: (context, state) {
            if (state is ShelterRequestsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShelterRequestsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ShelterRequestsLoaded) {
              if (state.requests.isEmpty) {
                return const Center(child: Text('No tienes solicitudes pendientes.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  return _RequestCard(request: state.requests[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AdoptionRequestEntity request;
  const _RequestCard({required this.request});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved': return 'APROBADO';
      case 'rejected': return 'RECHAZADO';
      default: return 'PENDIENTE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Interesado en: ${request.petName ?? "Mascota"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor(request.status)),
                  ),
                  child: Text(
                    _getStatusText(request.status),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('De: ${request.adopterName ?? "Usuario Anónimo"}'),
            const SizedBox(height: 4),
            Text(
              '"${request.message}"',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            
            // Botones de acción solo si está pendiente
            if (request.status == 'pending') ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context.read<ShelterRequestsBloc>().add(
                        UpdateRequestStatusEvent(request.id!, 'rejected'),
                      );
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ShelterRequestsBloc>().add(
                        UpdateRequestStatusEvent(request.id!, 'approved'),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Aprobar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}