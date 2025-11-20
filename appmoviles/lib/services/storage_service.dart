import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();

  /// Método para seleccionar una imagen (solo pick)
  Future<File?> pickImage() async {
    //XFile se usa desde fuentes externas ya sea 
    //galeria o camara
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return null;

    return File(picked.path); //convertir a de XFile a File
  }

  /// Método para subir la imagen ya seleccionada
  Future<String?> uploadProfilePicture(File file) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final ext = file.path.split('.').last;

      final fileName = "$userId.$ext";

      await supabase.storage
          .from("perfiles")
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      //return the url to be stored on the database 
      return supabase.storage.from("perfiles").getPublicUrl(fileName);

    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }
}
