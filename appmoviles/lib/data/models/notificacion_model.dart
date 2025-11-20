class Notificacion {
  final String idNotificacion;
  final String usuarioFK;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;

  Notificacion({
    required this.idNotificacion,
    required this.usuarioFK,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.leida,
  });

  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      idNotificacion: map['id_notificacion'],
      usuarioFK: map['usuarioFK'],
      titulo: map['titulo'],
      mensaje: map['mensaje'],
      fecha: DateTime.parse(map['fecha']),
      leida: map['leida'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_notificacion': idNotificacion,
      'usuarioFK': usuarioFK,
      'titulo': titulo,
      'mensaje': mensaje,
      'fecha': fecha.toIso8601String(),
      'leida': leida,
    };
  }
}
