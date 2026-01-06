import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/pet_bloc.dart';
import '../../domain/entities/pet_entity.dart';
import '../../../maps/presentation/pages/map_page.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../adoption/presentation/bloc/adoption_bloc.dart';

class PetFeedPage extends StatelessWidget {
  const PetFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PetBloc>()..add(const GetPetsRequested()), // Carga inicial
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Adopta un Amigo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const MapPage())
                );
              },
            ),
             // Aquí iría el botón del Chatbot Gemini
             IconButton(
                icon: const Icon(Icons.smart_toy_outlined), // Icono de Robot/IA
                tooltip: 'Asistente IA',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatPage()),
                  );
                },
              ),
          ],
        ),
        body: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state is PetLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PetsLoaded) {
              if (state.pets.isEmpty) {
                return const Center(child: Text('No hay mascotas disponibles por ahora.'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PetBloc>().add(const GetPetsRequested());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.pets.length,
                  itemBuilder: (context, index) {
                    return _PetCard(pet: state.pets[index]);
                  },
                ),
              );
            } else if (state is PetError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetEntity pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen de la mascota
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 200,
              child: pet.photos.isNotEmpty
                  ? Image.network(
                      pet.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 50),
                    )
                  : const Center(child: Icon(Icons.pets, size: 50, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    _GenderChip(gender: pet.gender),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${pet.breed ?? "Mestizo"} • ${pet.age} años',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAdoptionDialog(context, pet);
                    },
                    child: const Text('Solicitar Adopción'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String gender;
  const _GenderChip({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isMale = gender == 'male';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMale ? Colors.blue[50] : Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isMale ? Icons.male : Icons.female,
            size: 16,
            color: isMale ? Colors.blue : Colors.pink,
          ),
          const SizedBox(width: 4),
          Text(
            isMale ? 'Macho' : 'Hembra',
            style: TextStyle(
              color: isMale ? Colors.blue : Colors.pink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void _showAdoptionDialog(BuildContext context, PetEntity pet) {
  final messageController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      // Proveemos el BLoC dentro del diálogo
      return BlocProvider(
        create: (_) => getIt<AdoptionBloc>(),
        child: BlocConsumer<AdoptionBloc, AdoptionState>(
          listener: (context, state) {
            if (state is AdoptionSuccess) {
              Navigator.pop(context); // Cierra el diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Solicitud enviada! El refugio te contactará.'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AdoptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AdoptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return AlertDialog(
              title: Text('Adoptar a ${pet.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cuéntale al refugio por qué quieres adoptar:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Hola, tengo espacio en casa y...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      context.read<AdoptionBloc>().add(
                            SubmitRequest(
                              petId: pet.id!, // Asegúrate que pet.id no sea null
                              shelterId: pet.shelterId,
                              message: messageController.text,
                            ),
                          );
                    }
                  },
                  child: const Text('Enviar Solicitud'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}