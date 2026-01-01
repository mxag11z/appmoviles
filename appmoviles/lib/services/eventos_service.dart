import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/evento_model.dart';

class EventoService {
  final SupabaseClient supabase;

  EventoService(this.supabase);

  /// Obtiene eventos publicados con paginación
  Future<List<Evento>> fetchPublishedEvents({
    required int offset,
    required int limit,
  }) async {
    final data = await supabase
        .from('evento')
        .select('''
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
        ''')
        .eq('status_fk', 3)
        .order('fechainicio', ascending: true)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((e) => Evento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el total de eventos publicados 
  Future<int> getTotalPublishedEventsCount() async {
    final response = await supabase
        .from('evento')
        .select('id_evento')
        .eq('status_fk', 3)
        .count(CountOption.exact); 
    
    return response.count;
  }
}