class OrganizerModel {
  final String idUsuario;

  OrganizerModel({required this.idUsuario});

  factory OrganizerModel.fromMap(Map<String, dynamic> map) {
    return OrganizerModel(
      idUsuario: map["idorganizador"],
    );
  }
}
