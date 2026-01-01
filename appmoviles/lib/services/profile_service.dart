import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/usuario_model.dart';
import '../data/models/student_model.dart';

class ProfileService {
  final SupabaseClient supabase;

  ProfileService(this.supabase);

  /// Obtiene el usuario actual
  Future<Usuario?> getCurrentUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('usuario')
        .select('*')
        .eq('id_usuario', user.id)
        .maybeSingle();

    if (response == null) return null;
    return Usuario.fromMap(response);
  }

  /// Obtiene los datos del estudiante
  Future<StudentModel?> getCurrentEstudiante() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('estudiante')
        .select('*')
        .eq('id_estudiante', user.id)
        .maybeSingle();

    if (response == null) return null;
    return StudentModel.fromMap(response);
  }

  /// Actualiza el nombre del usuario
  Future<void> updateNombre({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await supabase.from('usuario').update({
      'nombre': nombre,
      'ap_paterno': apellidoPaterno,
      'ap_materno': apellidoMaterno,
    }).eq('id_usuario', userId);
  }

  /// Actualiza los intereses del estudiante
  Future<void> updateIntereses(List<String> intereses) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await supabase.from('estudiante').update({
      'intereses': intereses,
    }).eq('id_estudiante', userId);
  }

  /// Sube una nueva foto de perfil y actualiza la URL en la base de datos
  Future<String?> updateFotoPerfil(File file) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final ext = file.path.split('.').last;
    final fileName = '$userId.$ext';

    await supabase.storage.from('profiles').upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final fotoUrl = supabase.storage.from('profiles').getPublicUrl(fileName);

    await supabase.from('usuario').update({
      'foto': fotoUrl,
    }).eq('id_usuario', userId);

    return fotoUrl;
  }

  /// Cierra sesión
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
