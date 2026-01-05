import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handler para mensajes en background (debe estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensaje en background: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin(); //plugin para la barra de estados del telefomno
  final SupabaseClient _supabase = Supabase.instance.client; //cliente supabase

  bool _isInitialized = false;

  /// Canal de notificaciones para Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'eventos_channel',
    'Notificaciones de Eventos',
    description: 'Notificaciones sobre eventos y recordatorios',
    importance: Importance.high,
  );

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configurar notificaciones locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap, //callback cuando un usuario da click en la notificacion
    );

    // Crear canal de Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Configurar handlers de FCM
    //cuando esta cerrada la app
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _isInitialized = true;
  }

  /// Solicitar permisos de notificación
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    //cuando se muestra en pantalla el modal para dar permisos de notificaciones

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Obtener el token FCM
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Guardar el token FCM en Supabase
  Future<void> saveTokenToSupabase() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final token = await getToken();
    if (token == null) return;

    // Primero eliminar este token de CUALQUIER otro usuario
    // Esto evita que dos usuarios tengan el mismo token (mismo dispositivo)
    await _supabase.from('usuario').update({
      'fcm_token': null,
      'fcm_token_updated_at': null,
    }).eq('fcm_token', token).neq('id_usuario', userId);

    // Ahora guardar el token solo para el usuario actual
    await _supabase.from('usuario').update({
      'fcm_token': token,
      'fcm_token_updated_at': DateTime.now().toIso8601String(),
    }).eq('id_usuario', userId);

    print('Token FCM guardado para usuario $userId: $token');

    // Escuchar cambios de token
    _messaging.onTokenRefresh.listen((newToken) async {
      // Limpiar token anterior de otros usuarios
      await _supabase.from('usuario').update({
        'fcm_token': null,
        'fcm_token_updated_at': null,
      }).eq('fcm_token', newToken).neq('id_usuario', userId);

      await _supabase.from('usuario').update({
        'fcm_token': newToken,
        'fcm_token_updated_at': DateTime.now().toIso8601String(),
      }).eq('id_usuario', userId);
      print('Token FCM actualizado: $newToken');
    });
  }

  /// Eliminar token FCM (al cerrar sesión)
  Future<void> removeToken() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('usuario').update({
      'fcm_token': null,
      'fcm_token_updated_at': null,
    }).eq('id_usuario', userId);

    await _messaging.deleteToken();
  }

  /// Manejar mensaje en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje en foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Notificación',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Manejar cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('App abierta desde notificación: ${message.data}');
    // Aquí puedes navegar a una pantalla específica según el payload
    _handleNotificationNavigation(message.data);
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cuando el usuario toca la notificación
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _handleNotificationNavigation(data);
    }
  }

  /// Navegar según el tipo de notificación
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Ejemplo: si la notificación tiene evento_id, navegar al detalle
    final eventoId = data['evento_id'];
    if (eventoId != null) {
      // Usar router para navegar - esto se implementa desde el provider
      print('Navegar a evento: $eventoId');
    }
  }

}
