import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> registerUser({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String email,
    required String password,
    required int rol,
    required List<String> intereses,
    File? fotoFile,
  }) async {
    try {
      // registro de auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return "Error creando usuario en Supabase Auth.";
      }

      final userId = authResponse.user!.id;

      // si existe fotografia subirla
      String? fotoUrl;
      if (fotoFile != null) {
        final ext = fotoFile.path.split('.').last;
        final fileName = "$userId.$ext";

        await supabase.storage.from("perfiles").upload(
          fileName,
          fotoFile,
          fileOptions: const FileOptions(upsert: true),
        );

        fotoUrl = supabase.storage.from("perfiles").getPublicUrl(fileName);
      }

      // insercion de usuarios
      await supabase.from("usuario").insert({
        "id_usuario": userId,
        "nombre": nombre,
        "ap_paterno": apellidoPaterno,
        "ap_materno": apellidoMaterno,
        "email": email,
        "rol": rol,
        "foto": fotoUrl
      });

      //manejo de roles
      if (rol == 1) {
        // ESTUDIANTE
        await supabase.from("estudiante").insert({
          "id_usuario": userId,
          "carreraFK": 1, // pendiente selector de carrera
          "semestre": 1,  // pendiente pedir semestre
          "intereses": intereses,
        });
      }

      if (rol == 2) {
        // ORGANIZADOR
        await supabase.from("organizador").insert({
          "id_usuario": userId,
        });
      }

      return null;

    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
