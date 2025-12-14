import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:appmoviles/data/models/usuario_model.dart';
import 'package:appmoviles/data/models/student_model.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> registerUser({
    required Usuario usuario,
    required String password,
    StudentModel? estudiante, 
    File? fotoFile,
  }) async {
    try {
      //Registro en Auth
      final authResponse = await supabase.auth.signUp(
        email: usuario.email,
        password: password,
      );

      if (authResponse.user == null) {
        return "Error creando usuario en Supabase Auth.";
      }

      final userId = authResponse.user!.id;

      //Subir foto si existe
      String? fotoUrl;
      if (fotoFile != null) {
        final ext = fotoFile.path.split('.').last;
        final fileName = "$userId.$ext";

        await supabase.storage.from("profiles").upload(
          fileName,
          fotoFile,
          fileOptions: const FileOptions(upsert: true),
        );

        fotoUrl = supabase.storage.from("profiles").getPublicUrl(fileName);
      }

      // Construir el usuario definitivo (con id + foto)
      final usuarioDb = Usuario(
        idUsuario: userId,
        nombre: usuario.nombre,
        apellidoPaterno: usuario.apellidoPaterno,
        apellidoMaterno: usuario.apellidoMaterno,
        email: usuario.email,
        rol: usuario.rol,
        foto: fotoUrl,
      );

      // Guardar en tabla usuario 
      await supabase.from("usuario").upsert(
            usuarioDb.toMap(),
            onConflict: "id_usuario",
          );

      // Manejo de roles
      if (usuario.rol == 1 && estudiante != null) {
        // ESTUDIANTE
        final estudianteDb = StudentModel(
          idUsuario: userId,
          carreraFK: estudiante.carreraFK,
          semestre: estudiante.semestre,
          intereses: estudiante.intereses,
        );

        await supabase.from("estudiante").upsert(
          estudianteDb.toMap(),
          onConflict: "id_estudiante",
        );
      }

      if (usuario.rol == 2) {
        // ORGANIZADOR
        await supabase.from("organizador").upsert(
          {
            "id_usuario": userId,
          },
          onConflict: "id_usuario",
        );
      }

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
