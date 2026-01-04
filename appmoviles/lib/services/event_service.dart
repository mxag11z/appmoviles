import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/evento_model.dart';

class CrudEventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //crear el evento
  Future<String?> crearEvento({required Evento evento, File? imagen}) async {
    try {
      // final user = _supabase.auth.currentUser;

      // if (user == null) {
      //   return 'Usuario no autenticado';
      // }

      String fotoUrl = '';

      //si la imagen del evento si existe
      if (imagen != null) {
        final ext = imagen.path.split('.').last;
        final fileName =
            'eventos/${DateTime.now().millisecondsSinceEpoch}.$ext';

        final uploadResponse = await _supabase.storage
            .from('eventos')
            .upload(fileName, imagen);

        fotoUrl = _supabase.storage.from('eventos').getPublicUrl(fileName);
      } else {
        print('no hay imagen');
      }

      final data = evento.toMap();
      data['foto'] = fotoUrl;

      data.forEach((k, v) => print('   $k → $v (${v.runtimeType})'));

      final response = await _supabase.from('evento').insert(data).select();

      return null;
    } catch (e, stack) {
      print(e);
      print(stack);
      return e.toString();
    }
  }

  //obeter una lista de los eventos (pending) del organizador actual
  Future<List<Evento>> obtenerEventos() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Usuario no autenticado');
        return [];
      }

      final response = await _supabase
          .from('evento')
          .select()
          .eq('organizadorfk', user.id)
          .inFilter('status_fk', [1])
          .order('fechainicio', ascending: false);

      print('obtenerEventos response: $response');

      return response.map<Evento>((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Error obteniendo eventos: $e');
      rethrow;
    }
  }

  //obeter una lista de los eventos aprobados del organizador actual
  Future<List<Evento>> obtenerEventosAprobados() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Usuario no autenticado');
        return [];
      }

      final response = await _supabase
          .from('evento')
          .select()
          .eq('organizadorfk', user.id)
          .inFilter('status_fk', [3])
          .order('fechainicio', ascending: false);

      print('obtenerEventos response: $response');

      return response.map<Evento>((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Error obteniendo eventos: $e');
      rethrow;
    }
  }

  //obeter una lista de los eventos pre-borrados
  Future<List<Evento>> obtenerEventosPreBorrados() async {
    try {
      final response = await _supabase
          .from('evento')
          .select()
          .inFilter('status_fk', [2])
          .order('fechainicio', ascending: false);

      print('obtenerEventos response: $response');

      return response.map<Evento>((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Error obteniendo eventos: $e');
      rethrow;
    }
  }

  //obeter una lista de los todos los eventos
  Future<List<Evento>> obtenerTodosEventos() async {
    try {
      final response = await _supabase
          .from('evento')
          .select()
          .inFilter('status_fk', [1, 2, 3])
          .order('fechainicio', ascending: false);

      print('obtenerEventos response: $response');

      return response.map<Evento>((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Error obteniendo eventos: $e');
      rethrow;
    }
  }

  //para filtrar eventos
  Future<List<Evento>> obtenerEventosFiltrados({
    int? categoria,
    String? ubicacion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = _supabase.from('evento').select().inFilter('status_fk', [
        1,
        2,
        3,
      ]);

      // filtro por categoria
      if (categoria != null) {
        query = query.eq('categoriafk', categoria);
      }

      // filtro por ubicacion
      if (ubicacion != null && ubicacion.isNotEmpty) {
        query = query.ilike('ubicacion', '%$ubicacion%');
      }

      // FILTRO FECHA INICIO
      if (fechaInicio != null) {
        query = query.gte('fechainicio', fechaInicio.toIso8601String());
      }

      // filtro fecha fin
      if (fechaFin != null) {
        query = query.lte('fechafin', fechaFin.toIso8601String());
      }

      // ordenar por fecha inicio descendente
      final response = await query.order('fechainicio', ascending: false);

      print('obtenerEventosFiltrados response: $response');

      return response.map<Evento>((e) => Evento.fromMap(e)).toList();
    } catch (e) {
      print('Error obteniendo eventos filtrados: $e');
      rethrow;
    }
  }

  //cancelar evento
  Future<String?> cancelarEvento(String idEvento) async {
    try {
      print('Cancelando evento con id: $idEvento');
      // final user = _supabase.auth.currentUser;
      // if (user == null) return 'Usuario no autenticado';

      await _supabase
          .from('evento')
          .update({'status_fk': 2}) //2 representa evento 'refused'
          .eq('id_evento', idEvento);

      return null;
    } catch (e) {
      print('Error cancelando evento: $e');
      return e.toString();
    }
  }

  //aprobar evento
  Future<String?> aprobarEvento(String idEvento) async {
    try {
      print('Aprobando evento con id: $idEvento');
      // final user = _supabase.auth.currentUser;
      // if (user == null) return 'Usuario no autenticado';

      await _supabase
          .from('evento')
          .update({'status_fk': 3}) //2 representa evento 'refused'
          .eq('id_evento', idEvento);

      return null;
    } catch (e) {
      print('Error cancelando evento: $e');
      return e.toString();
    }
  }

  /// editar evento (SIN imagen)
  Future<String?> editarEvento({
    required String idEvento,
    required Evento evento,
  }) async {
    try {
      // final user = _supabase.auth.currentUser;
      // if (user == null) return 'Usuario no autenticado';

      final updateData = {
        'titulo': evento.titulo,
        'descripcion': evento.descripcion,
        'cupo': evento.cupo,
        'categoriafk': evento.categoriaFk,
      };

      final response = await _supabase
          .from('evento')
          .update(updateData)
          .eq('id_evento', idEvento)
          // .eq('organizadorfk', user.id)
          .select();

      if (response.isEmpty) {
        return 'No se actualizó ningún registro (verifica permisos)';
      }

      return null;
    } catch (e) {
      print('Error editarEvento: $e');
      return e.toString();
    }
  }

  /// editar evento con imagen
  Future<String?> editarEventoConImagen({
    required String idEvento,
    required Evento evento,
    File? nuevaImagen,
  }) async {
    try {
      // final user = _supabase.auth.currentUser;
      // if (user == null) return 'Usuario no autenticado';

      String fotoUrl = evento.foto ?? '';

      if (nuevaImagen != null) {
        final ext = nuevaImagen.path.split('.').last;
        final fileName =
            'eventos/${DateTime.now().millisecondsSinceEpoch}.$ext';

        await _supabase.storage
            .from('eventos')
            .upload(
              fileName,
              nuevaImagen,
              fileOptions: const FileOptions(upsert: true),
            );

        fotoUrl = _supabase.storage.from('eventos').getPublicUrl(fileName);
      }

      final updateData = {
        'titulo': evento.titulo,
        'descripcion': evento.descripcion,
        'cupo': evento.cupo,
        'categoriafk': evento.categoriaFk,
        'foto': fotoUrl,
      };

      final response = await _supabase
          .from('evento')
          .update(updateData)
          .eq('id_evento', idEvento)
          // .eq('organizadorfk', user.id)
          .select();

      if (response.isEmpty) {
        return 'No se actualizó ningún registro (verifica permisos)';
      }

      return null;
    } catch (e) {
      print('Error editarEventoConImagen: $e');
      return e.toString();
    }
  }
}

/// Mapa de estados a los IDs definidos en evento_status.
/// Ajusta los valores si tus IDs son distintos.
// Ajuste para coincidir con tu BD:
// En tus registros se ve mayormente status_fk=3 y 2.
// Usamos 3 como 'pendiente' y 2 como 'aprobado'.
const Map<String, int> _statusIds = {
  'pendiente': 3,
  'aprobado': 2,
  'rechazado': 1,
};

class EventService {
  final SupabaseClient supabase;

  EventService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<List<Evento>> getEventos() async {
    try {
      final statusId = 1;
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

  Future<List<Evento>> getTodosLosEventos() async {
    try {
      final res = await supabase
          .from('evento')
          .select()
          .order('fechainicio', ascending: false);

      final data = res as List<dynamic>;
      print(  'getTodosLosEventos data: $data');
      return data
          .map((item) => Evento.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      // ignore: avoid_print
      print('Error getTodosLosEventos: $e\n$st');
      return [];
    }
  }

  Future<void> aprobarEvento(String idEvento) async {
     await supabase
      .from('evento')
      .update({'status_fk': 3})
      .eq('id_evento', idEvento);
  }

  Future<void> rechazarEvento(String idEvento) async {
    await supabase
        .from('evento')
        .update({'status_fk': 2})
        .eq('id_evento', idEvento);
  }

  Future<void> volverAPendiente(String idEvento) async {
    final statusId = _statusIds['pendiente']!;
    await supabase
        .from('evento')
        .update({'status_fk': statusId})
        .eq('id_evento', idEvento);
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
