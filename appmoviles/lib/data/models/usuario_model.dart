class Usuario {
  final String idUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final int rol;
  final String? foto;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    required this.rol,
    this.foto,
  });

  /// map---> modelo
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'],
      nombre: map['nombre'],
      apellidoPaterno: map['ap_paterno'],
      apellidoMaterno: map['ap_materno'],
      email: map['email'],
      rol: map['rolfk'],
      foto: map['foto'],
    );
  }

  /// modelo ---> mapa (para inserts o updates)
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'ap_paterno':apellidoPaterno,
      'ap_materno':apellidoMaterno,
      'email': email,
      'rolfk': rol,
      'foto': foto,
    };
  }
}
