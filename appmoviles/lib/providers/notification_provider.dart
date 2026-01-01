import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Estado de las notificaciones
class NotificationState {
  final bool isInitialized;
  final bool hasPermission;
  final String? token;
  final bool isLoading;
  final String? error;
  // Preferencias de notificaciones
  final bool eventReminders;
  final bool newEvents;

  const NotificationState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.token,
    this.isLoading = false,
    this.error,
    this.eventReminders = true,
    this.newEvents = true,
  });

  NotificationState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    String? token,
    bool? isLoading,
    String? error,
    bool? eventReminders,
    bool? newEvents,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      eventReminders: eventReminders ?? this.eventReminders,
      newEvents: newEvents ?? this.newEvents,
    );
  }
}

/// Provider para manejar notificaciones
final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return const NotificationState();
  }

  /// Inicializar notificaciones (llamar después del login)
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final service = ref.read(notificationServiceProvider);

      // Inicializar el servicio
      await service.initialize();

      // Solicitar permisos
      final hasPermission = await service.requestPermission();

      if (hasPermission) {
        // Obtener y guardar token
        final token = await service.getToken();
        await service.saveTokenToSupabase();

        // DEBUG: Imprime el token para probar en Firebase Console
        print('═══════════════════════════════════════════');
        print('FCM TOKEN (copia esto para probar):');
        print(token);
        print('═══════════════════════════════════════════');

        state = NotificationState(
          isInitialized: true,
          hasPermission: true,
          token: token,
        );
      } else {
        state = const NotificationState(
          isInitialized: true,
          hasPermission: false,
        );
      }
    } catch (e) {
      print('Error inicializando notificaciones: $e');
      state = NotificationState(
        isInitialized: false,
        error: e.toString(),
      );
    }
  }

  /// Solicitar permisos manualmente
  Future<bool> requestPermission() async {
    final service = ref.read(notificationServiceProvider);
    final hasPermission = await service.requestPermission();

    if (hasPermission) {
      await service.saveTokenToSupabase();
    }

    state = state.copyWith(hasPermission: hasPermission);
    return hasPermission;
  }

  /// Limpiar token (al cerrar sesión)
  Future<void> clearToken() async {
    final service = ref.read(notificationServiceProvider);
    await service.removeToken();
    state = const NotificationState();
  }

  /// Activar/desactivar recordatorios de eventos
  void toggleEventReminders(bool value) {
    state = state.copyWith(eventReminders: value);
  }

  /// Activar/desactivar notificaciones de nuevos eventos
  void toggleNewEvents(bool value) {
    state = state.copyWith(newEvents: value);
  }
}
