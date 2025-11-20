class Usuario {
  final String idUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final int rol;
  final List<String> intereses;
  final String? foto;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.rol,
    required this.intereses,
    this.foto,
  });

  /// map---> modelo
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'],
      nombre: map['nombre'],
      apellidoPaterno: map['apellidoPaterno'],
      apellidoMaterno: map['apellidoMaterno'],
      email: map['email'],
      rol: map['rolFK'],
      intereses: List<String>.from(map['intereses'] ?? []),
      foto: map['foto'],
    );
  }

  /// modelo ---> mapa (para inserts o updates)
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'apellidoPaterno':apellidoPaterno,
      'apellidoMaterno':apellidoMaterno,
      'email': email,
      'rolFK': rol,
      'intereses': intereses,
      'foto': foto,
    };
  }
}
