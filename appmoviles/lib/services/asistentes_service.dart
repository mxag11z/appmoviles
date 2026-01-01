import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/asistente_evento_model.dart';

class AsistentesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  ///obtener asistentes de un evento por UUID
  Future<List<AsistenteEvento>> obtenerAsistentesPorEvento(
    String eventoId,
  ) async {
    try {
      final response = await _supabase
          .from('estudiante_evento')
          .select(''' 
              estudiante (
                id_estudiante,
                usuario (
                  id_usuario,
                  foto,
                  nombre,
                  ap_paterno,
                  ap_materno,
                  email
                )
              )
            ''')
          .eq('id_evento', eventoId);
        
        
        print(  'Asistentes response: $response' );

      return response
          .map<AsistenteEvento>((e) => AsistenteEvento.fromMap(e))
          .toList();
    } catch (e) {
      print('Error obteniendo asistentes: $e');
      rethrow;
    }
  }
}
