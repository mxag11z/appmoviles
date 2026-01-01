import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/evento_model.dart';

class RegistroEventoService {
  final SupabaseClient supabase;

  RegistroEventoService(this.supabase);

  /// Obtiene el ID del estudiante actual basado en el usuario autenticado
  Future<String?> getCurrentEstudianteId() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('estudiante')
        .select('id_estudiante')
        .eq('id_estudiante', userId)
        .maybeSingle();

    return data?['id_estudiante'] as String?;
  }

  /// Registra al estudiante en un evento
  Future<void> registerToEvent(String estudianteId, String eventoId) async {
    await supabase.from('estudiante_evento').insert({
      'id_estudiante': estudianteId,
      'id_evento': eventoId,
    });
  }

  /// Cancela el registro del estudiante en un evento
  Future<void> unregisterFromEvent(String estudianteId, String eventoId) async {
    await supabase
        .from('estudiante_evento')
        .delete()
        .eq('id_estudiante', estudianteId)
        .eq('id_evento', eventoId);
  }

  /// Verifica si el estudiante está registrado en un evento
  Future<bool> isRegistered(String estudianteId, String eventoId) async {
    final data = await supabase
        .from('estudiante_evento')
        .select('id_estudiante')
        .eq('id_estudiante', estudianteId)
        .eq('id_evento', eventoId)
        .maybeSingle();

    return data != null;
  }

  /// Obtiene el número de estudiantes registrados en un evento
  Future<int> getRegistradosCount(String eventoId) async {
    final response = await supabase
        .from('estudiante_evento')
        .select('id_estudiante')
        .eq('id_evento', eventoId)
        .count(CountOption.exact);

    return response.count;
  }

  /// Obtiene todos los eventos en los que el estudiante está registrado
  Future<List<Evento>> fetchMyRegisteredEvents(String estudianteId) async {
    final data = await supabase
        .from('estudiante_evento')
        .select('''
          id_evento,
          evento!estudiante_evento_event_fk (
            id_evento,
            titulo,
            descripcion,
            fechainicio,
            fechafin,
            ubicacion,
            organizadorfk,
            foto,
            cupo,
            categoria:categoriafk ( nombre ),
            evento_status:status_fk ( nombre )
          )
        ''')
        .eq('id_estudiante', estudianteId);

    return (data as List).map((item) {
      final eventoData = item['evento'] as Map<String, dynamic>;
      return Evento.fromMap(eventoData);
    }).toList();
  }
}
