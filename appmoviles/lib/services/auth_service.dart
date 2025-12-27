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

        await supabase.storage
            .from("profiles")
            .upload(
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
      await supabase
          .from("usuario")
          .upsert(usuarioDb.toMap(), onConflict: "id_usuario");

      // Manejo de roles
      if (usuario.rol == 1 && estudiante != null) {
        // ESTUDIANTE
        final estudianteDb = StudentModel(
          idUsuario: userId,
          carreraFK: estudiante.carreraFK,
          semestre: estudiante.semestre,
          intereses: estudiante.intereses,
        );

        await supabase
            .from("estudiante")
            .upsert(estudianteDb.toMap(), onConflict: "id_estudiante");
      }

      if (usuario.rol == 2) {
        // ORGANIZADOR
        await supabase.from("organizador").upsert({
          "id_usuario": userId,
        }, onConflict: "id_usuario");
      }

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  //Login feature
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return "Unknown error while logging in.";
      }
      if (user.emailConfirmedAt == null) {
        await supabase.auth.signOut();
        return "Please confirm your email before logging in. Check your inbox.";
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Enviar correo de recuperación de contraseña
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null; // éxito
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Verificar el token y actualizar la contraseña
  Future<String?> resetPasswordWithToken({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final verifyRes = await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );

      if (verifyRes.user == null) {
        return "Token inválido o expirado.";
      }

      final updateRes = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateRes.user == null) {
        return "No se pudo actualizar la contraseña.";
      }

      return null; // éxito
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
