class Evento {
  final String idEvento;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String ubicacion;
  final int cupo;
  final String organizadorFk;
  final int categoriaFk;
  final String foto;
  final int estado;

  Evento({
    required this.idEvento,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.ubicacion,
    required this.cupo,
    required this.organizadorFk,
    required this.categoriaFk,
    required this.foto,
    required this.estado,
  });

  /// de base de datos a app
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      idEvento: map['id_evento'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fechaInicio: DateTime.parse(map['fechainicio']),
      fechaFin: DateTime.parse(map['fechafin']),
      ubicacion: map['ubicacion'],
      cupo: map['cupo'],
      organizadorFk: map['organizadorfk'],
      categoriaFk: map['categoriafk'],
      foto: map['foto'] ?? '',
      estado: map['status_fk'],
    );
  }

  /// de app a base de datos
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fechainicio': fechaInicio.toIso8601String(),
      'fechafin': fechaFin.toIso8601String(),
      'ubicacion': ubicacion,
      'cupo': cupo,
      'organizadorfk': organizadorFk,
      'categoriafk': categoriaFk,
      'foto': foto,
      'status_fk': estado,
    };
  }

  
  Evento copyWith({
    String? idEvento,
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? ubicacion,
    int? cupo,
    String? organizadorFk,
    int? categoriaFk,
    String? foto,
    int? estado,
  }) {
    return Evento(
      idEvento: idEvento ?? this.idEvento,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      ubicacion: ubicacion ?? this.ubicacion,
      cupo: cupo ?? this.cupo,
      organizadorFk: organizadorFk ?? this.organizadorFk,
      categoriaFk: categoriaFk ?? this.categoriaFk,
      foto: foto ?? this.foto,
      estado: estado ?? this.estado,
    );
  }
}
