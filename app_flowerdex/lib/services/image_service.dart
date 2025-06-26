import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mostrar opciones para seleccionar imagen
  static Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error al seleccionar imagen: $e');
      }
      return null;
    }
  }

  // Tomar foto con la cámara
  static Future<XFile?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error al tomar foto: $e');
      }
      return null;
    }
  }

  // Subir imagen a Firebase Storage
  static Future<String?> uploadImage(XFile imageFile, String plantId) async {
    try {
      // Crear referencia única para la imagen
      final String fileName = 'plants/$plantId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);

      // Subir archivo
      final UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(bytes);
      } else {
        uploadTask = storageRef.putFile(File(imageFile.path));
      }

      // Esperar a que termine la subida
      final TaskSnapshot snapshot = await uploadTask;

      // Obtener URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
      }
      return null;
    }
  }

  // Eliminar imagen de Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return true;

      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar imagen: $e');
      }
      return false;
    }
  }
}