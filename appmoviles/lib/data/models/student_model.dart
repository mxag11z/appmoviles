class StudentModel {
  final String idUsuario;
  final int carreraFK;
  final int semestre;
  final List<String> intereses;

  StudentModel({
    required this.idUsuario,
    required this.carreraFK,
    required this.semestre,
    required this.intereses,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      idUsuario: map["id_usuario"],
      carreraFK: map["carreraFK"],
      semestre: map["semestre"],
      intereses: List<String>.from(map["intereses"] ?? []),
    );
  }
}
