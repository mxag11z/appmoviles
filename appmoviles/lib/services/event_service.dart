import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/data/models/evento_model.dart';


class EventService {
  final supabase = Supabase.instance.client;

  Future<List<Evento>> getEventos() async {
    final res = await supabase.from('evento').select();

    // res viene como List<dynamic>
    final data = res as List<dynamic>;

  return data
    .map((item) => Evento.fromMap(item as Map<String, dynamic>))
    .toList();

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
