import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/evento_model.dart';

/// Mapa de estados a los IDs definidos en evento_status.
/// Ajusta los valores si tus IDs son distintos.
const Map<String, int> _statusIds = {
  'pendiente': 1,
  'aprobado': 2,
  'rechazado': 3,
};

class EventService {
  final SupabaseClient supabase;

  EventService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<List<Evento>> getEventos({String estado = 'pendiente'}) async {
    try {
      final statusId = _statusIds[estado] ?? _statusIds['pendiente']!;
      final res = await supabase
          .from('evento')
          .select()
          .eq('status_fk', statusId)
          .order('fechainicio', ascending: true);

      final data = res as List<dynamic>;
      return data
          .map((item) => Evento.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      // ignore: avoid_print
      print('Error getEventos: $e\n$st');
      return [];
    }
  }

  Future<void> aprobarEvento(String idEvento) async {
    final statusId = _statusIds['aprobado']!;
    await supabase
        .from('evento')
        .update({'status_fk': statusId}).eq('id_evento', idEvento);
  }

  Future<void> rechazarEvento(String idEvento) async {
    final statusId = _statusIds['rechazado']!;
    await supabase
        .from('evento')
        .update({'status_fk': statusId}).eq('id_evento', idEvento);
  }

  Future<String?> createEvento(Evento evento) async {
    try {
      await supabase.from('evento').insert(evento.toMap());
      return null;
    } catch (e, st) {
      // ignore: avoid_print
      print('Error createEvento: $e\n$st');
      return e.toString();
    }
  }
}