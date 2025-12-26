import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/evento_model.dart';

class EventService {
  final supabase = Supabase.instance.client;

  Future<List<Evento>> getEventos({String estado = 'pendiente'}) async {
    final res = await supabase
        .from('evento')
        .select()
        .eq('estado', estado)
        .order('fecha_inicio', ascending: true);

    final data = res as List<dynamic>;
    return data
        .map((item) => Evento.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> aprobarEvento(String idEvento) async {
    await supabase.from('evento').update({'estado': 'aprobado'}).eq('id_evento', idEvento);
  }

  Future<void> rechazarEvento(String idEvento) async {
    await supabase.from('evento').update({'estado': 'rechazado'}).eq('id_evento', idEvento);
  }

  Future<String?> createEvento(Evento evento) async {
    try {
      await supabase.from('evento').insert(evento.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
