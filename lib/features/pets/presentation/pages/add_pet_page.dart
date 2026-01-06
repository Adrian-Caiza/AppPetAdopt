import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/pet_entity.dart';
import '../bloc/pet_bloc.dart'; // Solo importamos el Bloc (que ya trae Event y State)
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_overlay.dart';

class AddPetPage extends StatelessWidget {
  final PetEntity? petToEdit;

  const AddPetPage({super.key, this.petToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PetBloc>(),
      child: _AddPetView(petToEdit: petToEdit),
    );
  }
}

class _AddPetView extends StatefulWidget {
  final PetEntity? petToEdit;
  const _AddPetView({this.petToEdit});

  @override
  State<_AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends State<_AddPetView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descController = TextEditingController();
  
  // Variables de Estado para Dropdowns
  String _species = 'dog';
  String _gender = 'male';
  String _size = 'medium';
  
  // Imágenes
  File? _selectedImage;
  String? _existingImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Si estamos editando, rellenamos los campos
    if (widget.petToEdit != null) {
      final pet = widget.petToEdit!;
      _nameController.text = pet.name;
      _breedController.text = pet.breed ?? '';
      _ageController.text = pet.age.toString();
      _descController.text = pet.description;
      
      // Aseguramos que los valores coincidan con las opciones de los dropdowns
      _species = ['dog', 'cat'].contains(pet.species) ? pet.species : 'dog';
      _gender = ['male', 'female'].contains(pet.gender) ? pet.gender : 'male';
      _size = ['small', 'medium', 'large'].contains(pet.size) ? pet.size : 'medium';
      
      if (pet.photos.isNotEmpty) {
        _existingImageUrl = pet.photos.first;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Validación de Imagen
      if (_selectedImage == null && _existingImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una imagen')),
        );
        return;
      }

      final isEditing = widget.petToEdit != null;

      // Creamos la entidad base
      final petData = PetEntity(
        id: isEditing ? widget.petToEdit!.id : null, // ID solo si editamos
        shelterId: isEditing ? widget.petToEdit!.shelterId : '', // ID Refugio (se llena en backend al crear)
        name: _nameController.text.trim(),
        species: _species,
        breed: _breedController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _gender,
        size: _size,
        description: _descController.text.trim(),
        photos: isEditing ? widget.petToEdit!.photos : [], // Fotos (se actualizan en backend)
        status: 'available',
      );

      if (isEditing) {
        // Enviar evento de Actualizar
        context.read<PetBloc>().add(UpdatePetRequested(pet: petData));
      } else {
        // Enviar evento de Crear
        context.read<PetBloc>().add(AddPetRequested(pet: petData, image: _selectedImage!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.petToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Mascota' : 'Nueva Mascota')),
      body: BlocConsumer<PetBloc, PetState>(
        listener: (context, state) {
          if (state is PetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEditing ? '¡Actualizado con éxito!' : '¡Publicado con éxito!')),
            );
            Navigator.pop(context, true); // Retorna true para refrescar la lista
          } else if (state is PetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is PetLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SELECCIÓN DE IMAGEN ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                          image: _getImageProvider(),
                        ),
                        child: (_selectedImage == null && _existingImageUrl == null)
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                  Text('Toca para agregar foto'),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO: NOMBRE ---
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Ej: Firulais',
                      prefixIcon: Icons.pets,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),

                    // --- FILA: ESPECIE y GÉNERO ---
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _species,
                            decoration: const InputDecoration(labelText: 'Especie', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'dog', child: Text('Perro')),
                              DropdownMenuItem(value: 'cat', child: Text('Gato')),
                            ],
                            onChanged: (v) => setState(() => _species = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Macho')),
                              DropdownMenuItem(value: 'female', child: Text('Hembra')),
                            ],
                            onChanged: (v) => setState(() => _gender = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CAMPO: RAZA ---
                    CustomTextField(
                      controller: _breedController,
                      label: 'Raza',
                      hint: 'Ej: Labrador',
                      prefixIcon: Icons.category,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),

                    // --- FILA: EDAD y TAMAÑO ---
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _ageController,
                            label: 'Edad (años)',
                            hint: 'Ej: 2',
                            prefixIcon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (int.tryParse(v) == null) return 'Inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _size,
                            decoration: const InputDecoration(labelText: 'Tamaño', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'small', child: Text('Pequeño')),
                              DropdownMenuItem(value: 'medium', child: Text('Mediano')),
                              DropdownMenuItem(value: 'large', child: Text('Grande')),
                            ],
                            onChanged: (v) => setState(() => _size = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CAMPO: DESCRIPCIÓN ---
                    CustomTextField(
                      controller: _descController,
                      label: 'Descripción / Historia',
                      hint: 'Cuenta un poco sobre la mascota...',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- BOTÓN DE ACCIÓN ---
                    ElevatedButton(
                      onPressed: state is PetLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isEditing ? 'GUARDAR CAMBIOS' : 'PUBLICAR MASCOTA',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DecorationImage? _getImageProvider() {
    if (_selectedImage != null) {
      return DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover);
    } else if (_existingImageUrl != null) {
      return DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover);
    }
    return null;
  }
}