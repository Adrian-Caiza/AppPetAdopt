// lib/features/pets/presentation/pages/shelter_pets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/pet_bloc.dart';
import 'add_pet_page.dart';


class ShelterPetsPage extends StatelessWidget {
  const ShelterPetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PetBloc>()..add(LoadShelterPets()), // Evento nuevo
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis Mascotas Publicadas')),
        body: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state is PetLoading) return const Center(child: CircularProgressIndicator());
            if (state is PetsLoaded) {
              if (state.pets.isEmpty) return const Center(child: Text('No has publicado mascotas.'));
              return ListView.builder(
                itemCount: state.pets.length,
                itemBuilder: (ctx, i) {
                  final pet = state.pets[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(pet.photos.first)),
                    title: Text(pet.name),
                    subtitle: Text(pet.status),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          context.read<PetBloc>().add(DeletePetRequested(pet.id!));
                        } else if (value == 'edit') {
                          // AQUÍ ESTÁ LA SOLUCIÓN:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddPetPage(petToEdit: pet), // Pasamos la mascota a editar
                            ),
                          ).then((_) {
                            // Cuando volvemos de editar, recargamos la lista para ver los cambios
                            context.read<PetBloc>().add(LoadShelterPets());
                          });
                        }
                        
                      },
                    ),
                  );
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