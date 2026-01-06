import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/pet_entity.dart';
import '../bloc/pet_bloc.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_overlay.dart';

class AddPetPage extends StatelessWidget {
  const AddPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PetBloc>(),
      child: const _AddPetView(),
    );
  }
}

class _AddPetView extends StatefulWidget {
  const _AddPetView();

  @override
  State<_AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends State<_AddPetView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descController = TextEditingController();
  
  String _species = 'dog';
  String _gender = 'male';
  String _size = 'medium';
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una imagen')),
        );
        return;
      }

      final newPet = PetEntity(
        shelterId: '', // Se llena en el backend
        name: _nameController.text,
        species: _species,
        breed: _breedController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        size: _size,
        description: _descController.text,
        photos: [], // Se llena en el backend
        status: 'available',
      );

      context.read<PetBloc>().add(AddPetRequested(pet: newPet, image: _selectedImage!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Mascota')),
      body: BlocConsumer<PetBloc, PetState>(
        listener: (context, state) {
          if (state is PetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Mascota publicada con éxito!')),
            );
            Navigator.pop(context); // Regresar al Dashboard
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
                    // Área de Imagen
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
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

                    // Campos de Texto
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Ej: Firulais',
                      prefixIcon: Icons.pets,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _breedController,
                            label: 'Raza',
                            hint: 'Ej: Mestizo',
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _ageController,
                            label: 'Edad (años)',
                            hint: 'Ej: 2',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dropdowns (Especie, Género, Tamaño)
                    _buildDropdown('Especie', _species, ['dog', 'cat'], (v) => setState(() => _species = v!)),
                    _buildDropdown('Género', _gender, ['male', 'female'], (v) => setState(() => _gender = v!)),
                    _buildDropdown('Tamaño', _size, ['small', 'medium', 'large'], (v) => setState(() => _size = v!)),

                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _descController,
                      label: 'Descripción / Historia',
                      hint: 'Cuenta un poco sobre su personalidad...',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is PetLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Publicar Mascota'),
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

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}