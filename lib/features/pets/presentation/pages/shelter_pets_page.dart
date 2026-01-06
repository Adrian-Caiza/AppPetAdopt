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
    // Definimos un color principal para esta pantalla (Teal es excelente para mascotas/salud)
    const primaryColor = Colors.teal;

    return BlocProvider(
      create: (_) => getIt<PetBloc>()..add(LoadShelterPets()),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Fondo muy suave para resaltar las tarjetas
        appBar: AppBar(
          title: const Text(
            'Mis Mascotas Publicadas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: primaryColor),
        ),
        body: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            if (state is PetLoading) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }
            
            if (state is PetsLoaded) {
              if (state.pets.isEmpty) {
                // --- ESTADO VACÍO MEJORADO ---
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no has publicado mascotas.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text('¡Dale al botón + para empezar!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // --- LISTA DE TARJETAS ---
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: state.pets.length,
                itemBuilder: (ctx, i) {
                  final pet = state.pets[i];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Opcional: Podrías navegar al detalle aquí si quisieras
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // --- FOTO DE LA MASCOTA ---
                              Hero(
                                tag: pet.id!,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage(pet.photos.first),
                                      fit: BoxFit.cover,
                                      onError: (_, __) => const AssetImage('assets/placeholder.png'), // Fallback si falla
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // --- INFORMACIÓN ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pet.breed ?? 'Raza desconocida',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // --- BADGE DE ESTADO ---
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: pet.status == 'available' 
                                            ? Colors.green.withOpacity(0.1) 
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        pet.status == 'available' ? 'Disponible' : pet.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: pet.status == 'available' ? Colors.green[700] : Colors.orange[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // --- MENÚ DE OPCIONES ---
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600]),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_rounded, color: Colors.blue[400], size: 20),
                                        const SizedBox(width: 12),
                                        const Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 20),
                                        const SizedBox(width: 12),
                                        const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    // Lógica original intacta
                                    context.read<PetBloc>().add(DeletePetRequested(pet.id!));
                                  } else if (value == 'edit') {
                                    // Lógica original intacta
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddPetPage(petToEdit: pet),
                                      ),
                                    ).then((_) {
                                      context.read<PetBloc>().add(LoadShelterPets());
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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