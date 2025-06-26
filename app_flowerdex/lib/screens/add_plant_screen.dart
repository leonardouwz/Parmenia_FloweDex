import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../services/image_service.dart';

class AddPlantScreen extends StatefulWidget {
  final Plant? plant; // Para editar plantas existentes

  const AddPlantScreen({super.key, this.plant});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _notesController = TextEditingController();
  int _wateringFrequency = 7;
  bool _isLoading = false;
  XFile? _selectedImage;
  String _currentImageUrl = '';

  bool get isEditing => widget.plant != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.plant!.name;
      _speciesController.text = widget.plant!.species;
      _notesController.text = widget.plant!.notes;
      _wateringFrequency = widget.plant!.wateringFrequency;
      _currentImageUrl = widget.plant!.imageUrl;
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_currentImageUrl.isNotEmpty || _selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar imagen'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? image = await ImageService.takePhoto();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImageService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = '';
    });
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String imageUrl = _currentImageUrl;

      // Subir nueva imagen si se seleccionó una
      if (_selectedImage != null) {
        final plantId = isEditing ? widget.plant!.id : DateTime.now().millisecondsSinceEpoch.toString();
        final uploadedUrl = await ImageService.uploadImage(_selectedImage!, plantId);
        if (uploadedUrl != null) {
          // Si hay una imagen anterior y se subió una nueva, eliminar la anterior
          if (_currentImageUrl.isNotEmpty && _currentImageUrl != uploadedUrl) {
            await ImageService.deleteImage(_currentImageUrl);
          }
          imageUrl = uploadedUrl;
        }
      }

      final plant = Plant(
        id: isEditing ? widget.plant!.id : '',
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        imageUrl: imageUrl,
        lastWatered: isEditing ? widget.plant!.lastWatered : DateTime.now(),
        wateringFrequency: _wateringFrequency,
        notes: _notesController.text.trim(),
        userId: user.uid,
      );

      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('plants')
            .doc(widget.plant!.id)
            .update(plant.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('plants')
            .add(plant.toMap());
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Planta actualizada exitosamente' : 'Planta agregada exitosamente'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la planta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return kIsWeb
          ? FutureBuilder<Uint8List>(
        future: _selectedImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            );
          }
          return CircularProgressIndicator();
        },
      )
          : Image.file(
        File(_selectedImage!.path),
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (_currentImageUrl.isNotEmpty) {
      return Image.network(
        _currentImageUrl,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 50, color: Colors.red);
        },
      );
    } else {
      return Icon(
        Icons.add_photo_alternate,
        size: 50,
        color: Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Planta' : 'Agregar Planta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Widget para imagen
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWidget(),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Toca para ${(_selectedImage != null || _currentImageUrl.isNotEmpty) ? 'cambiar' : 'agregar'} imagen',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la planta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _speciesController,
                decoration: InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la especie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frecuencia de riego',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Cada $_wateringFrequency días'),
                      Slider(
                        value: _wateringFrequency.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                        label: '$_wateringFrequency días',
                        onChanged: (value) {
                          setState(() {
                            _wateringFrequency = value.round();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditing ? 'Actualizar Planta' : 'Guardar Planta',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}