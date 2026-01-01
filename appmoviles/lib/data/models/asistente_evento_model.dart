class AsistenteEvento {
  final String estudianteId;
  final String nombre;
  final String email;
  final String? foto;

  AsistenteEvento({
    required this.estudianteId,
    required this.nombre,
    required this.email,
    this.foto,
  });

  factory AsistenteEvento.fromMap(Map<String, dynamic> map) {
    final estudiante = map['estudiante'] as Map<String, dynamic>;
    final usuario = estudiante['usuario'] as Map<String, dynamic>;

    return AsistenteEvento(
      estudianteId: estudiante['id_estudiante'], 
      nombre: usuario['nombre'],
      email: usuario['email'],
      foto: usuario['foto'], 
    );
  }
}
