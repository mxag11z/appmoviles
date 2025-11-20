class Evento {
  final String idEvento;
  final String titulo;
  final String descripcion;
  final String categoria;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String lugar;
  final String organizadorFK;
  final String estado;
  final String foto; 

  Evento({
    required this.idEvento,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fechaInicio,
    required this.fechaFin,
    required this.lugar,
    required this.organizadorFK,
    required this.estado,
    required this.foto,
  });

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      idEvento: map['id_evento'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFin: DateTime.parse(map['fecha_fin']),
      lugar: map['lugar'],
      organizadorFK: map['organizadorFK'],
      estado: map['estado'],
      foto: map['foto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_evento': idEvento,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'lugar': lugar,
      'organizadorFK': organizadorFK,
      'estado': estado,
      'foto': foto,
    };
  }
}
