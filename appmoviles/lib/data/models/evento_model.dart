class Evento {
  final String idEvento;
  final String titulo;
  final String descripcion;
  final String categoriaNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String ubicacion;
  final String organizadorFK;
  final String status;
  final String? foto;
  final int? cupo;

  Evento({
    required this.idEvento,
    required this.titulo,
    required this.descripcion,
    required this.categoriaNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.ubicacion,
    required this.organizadorFK,
    required this.status,
    this.foto,
    this.cupo,
  });

  /// de base de datos a app
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      idEvento: map['id_evento'] as String,
      titulo: map['titulo'] as String,
      descripcion: (map['descripcion'] ?? '') as String,
      categoriaNombre: (map['categoria']?['nombre'] ?? 'Sin categoría') as String,
      fechaInicio: _parseDate(map['fechainicio']),
      fechaFin: _parseDate(map['fechafin']),
      ubicacion: (map['ubicacion'] ?? '') as String,
      organizadorFK: (map['organizadorfk'] ?? '') as String,
      status: (map['evento_status']?['nombre'] ?? '') as String,
      foto: map['foto'] as String?,
      cupo: map['cupo'] as int?,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final str = value.toString();
    // Si es solo fecha (YYYY-MM-DD), agregar hora por defecto
    if (str.length == 10) {
      return DateTime.parse('${str}T00:00:00');
    }
    return DateTime.parse(str);
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
