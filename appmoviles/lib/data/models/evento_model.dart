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
  final int cupo;

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
    this.cupo = 0,
  });

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      idEvento: map['id_evento'] ?? '',
      titulo: map['titulo'] ?? 'Sin título',
      descripcion: map['descripcion'] ?? 'Sin descripción',
      categoria: map['categoriafk']?.toString() ?? '0',
      fechaInicio: map['fechainicio'] != null 
          ? DateTime.parse(map['fechainicio']) 
          : DateTime.now(),
      fechaFin: map['fechafin'] != null 
          ? DateTime.parse(map['fechafin']) 
          : DateTime.now(),
      lugar: map['ubicacion'] ?? 'Sin ubicación',
      organizadorFK: map['organizadorfk'] ?? '',
      estado: map['status_fk']?.toString() ?? '1',
      foto: map['foto'] ?? '',
      cupo: map['cupo'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_evento': idEvento,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoriafk': int.tryParse(categoria) ?? 0,
      'fechainicio': fechaInicio.toIso8601String(),
      'fechafin': fechaFin.toIso8601String(),
      'ubicacion': lugar,
      'organizadorfk': organizadorFK,
      'status_fk': int.tryParse(estado) ?? 1,
      'foto': foto,
      'cupo': cupo,
    };
  }
}
