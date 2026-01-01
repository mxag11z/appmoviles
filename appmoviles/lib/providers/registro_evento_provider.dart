import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/registro_evento_service.dart';
import '../data/models/evento_model.dart';

final registroEventoServiceProvider = Provider<RegistroEventoService>((ref) {
  return RegistroEventoService(Supabase.instance.client);
});

/// Provider para obtener el ID del estudiante actual
final currentEstudianteIdProvider = FutureProvider<String?>((ref) async {
  final service = ref.read(registroEventoServiceProvider);
  return service.getCurrentEstudianteId();
});

/// Provider para verificar si el usuario está registrado en un evento específico
final isRegisteredProvider =
    FutureProvider.family<bool, String>((ref, eventoId) async {
  final estudianteId = await ref.watch(currentEstudianteIdProvider.future);
  if (estudianteId == null) return false;

  final service = ref.read(registroEventoServiceProvider);
  return service.isRegistered(estudianteId, eventoId);
});

/// Provider para obtener el número de registrados en un evento
final registradosCountProvider =
    FutureProvider.family<int, String>((ref, eventoId) async {
  final service = ref.read(registroEventoServiceProvider);
  return service.getRegistradosCount(eventoId);
});

/// Provider para obtener los eventos registrados del usuario
final myRegisteredEventsProvider =
    AsyncNotifierProvider<MyRegisteredEventsNotifier, List<Evento>>(
  MyRegisteredEventsNotifier.new,
);

class MyRegisteredEventsNotifier extends AsyncNotifier<List<Evento>> {
  @override
  Future<List<Evento>> build() async {
    return _fetchMyEvents();
  }

  Future<List<Evento>> _fetchMyEvents() async {
    final estudianteId =
        await ref.read(currentEstudianteIdProvider.future);
    if (estudianteId == null) return [];

    final service = ref.read(registroEventoServiceProvider);
    return service.fetchMyRegisteredEvents(estudianteId);
  }

  /// Registrarse a un evento
  Future<bool> registerToEvent(String eventoId) async {
    final estudianteId =
        await ref.read(currentEstudianteIdProvider.future);
    if (estudianteId == null) {
      print('ERROR: estudianteId es null - usuario no encontrado en tabla estudiante');
      return false;
    }

    try {
      final service = ref.read(registroEventoServiceProvider);
      await service.registerToEvent(estudianteId, eventoId);

      // Invalidar providers relacionados
      ref.invalidate(isRegisteredProvider(eventoId));
      ref.invalidate(registradosCountProvider(eventoId));

      // Refrescar la lista de mis eventos
      state = await AsyncValue.guard(() => _fetchMyEvents());

      return true;
    } catch (e) {
      print('ERROR al registrar evento: $e');
      return false;
    }
  }

  /// Cancelar registro de un evento
  Future<bool> unregisterFromEvent(String eventoId) async {
    final estudianteId =
        await ref.read(currentEstudianteIdProvider.future);
    if (estudianteId == null) return false;

    try {
      final service = ref.read(registroEventoServiceProvider);
      await service.unregisterFromEvent(estudianteId, eventoId);

      // Invalidar providers relacionados
      ref.invalidate(isRegisteredProvider(eventoId));
      ref.invalidate(registradosCountProvider(eventoId));

      // Refrescar la lista de mis eventos
      state = await AsyncValue.guard(() => _fetchMyEvents());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refrescar la lista
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMyEvents());
  }
}
